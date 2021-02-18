extends Node2D

# Change based on geography (bigger more lag but smoother?)
const INTERPOLATION_OFFSET = 100

var players_dict = {}
var last_world_state = 0
var world_state_buffer = []

onready var player_actual = preload("res://Player/Player.tscn")
onready var player_template = preload("res://Player/PlayerTemplate.tscn")
onready var players = $Objects/Players


func _physics_process(delta):
	var render_time = OS.get_system_time_msecs() - INTERPOLATION_OFFSET
	# print(world_state_buffer)
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].t:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:  # We have a future state
			world_state_buffer_interpolate(render_time)
		elif render_time > world_state_buffer[1].t:  # We have no future state
			world_state_buffer_extrapolate(render_time)


# world_state: t=time, p=position
# world_state_buffer = [pastpast, past, future, futurefuture]


func spawn_player(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id and not player_id in players_dict:
		# The client user 
		print("Spawning client user")
		instance_player(player_id, spawn_position, player_actual)
	else:
		# Spawn other players
		if not player_id in players_dict:
			print("spawning ", player_id)
			instance_player(player_id, spawn_position, player_template)


func instance_player(player_id, spawn_position, scene):
	var player = scene.instance()
	var basic = AllPlayersInfo.basics[player_id]
	player.init(player_id, spawn_position, basic)
	players.add_child(player)
	players_dict[player_id] = player


func despawn_player(player_id):
	print("despawning ", player_id)
	players_dict[player_id].queue_free()
	players_dict.erase(player_id)
	for world_state in world_state_buffer:
		if player_id in world_state:
			world_state.erase(player_id)


func update_world_state(world_state):
	if world_state.t > last_world_state:
		last_world_state = world_state.t
		world_state_buffer.append(world_state)


func world_state_buffer_interpolate(render_time):
	var interpolation_factor = (
		float(render_time - world_state_buffer[1].t)
		/ float(world_state_buffer[2].t - world_state_buffer[1].t)
	)
	for player_id in world_state_buffer[2]:
		if (
			str(player_id) == "t"
			or player_id == get_tree().get_network_unique_id()
			or not world_state_buffer[0].has(player_id)
		):
			continue
		if player_id in players_dict:
			var position = lerp(
				world_state_buffer[1][player_id].p,
				world_state_buffer[2][player_id].p,
				interpolation_factor
			)
			players_dict[player_id].move_player(position)
		else:
			spawn_player(player_id, world_state_buffer[2][player_id].p)


func world_state_buffer_extrapolate(render_time):
	var extrapolation_factor = (
		(
			float(render_time - world_state_buffer[0].t)
			/ (float(world_state_buffer[1].t - world_state_buffer[0].t))
		)
		- 1.0
	)
	for player_id in world_state_buffer[1]:
		if (
			str(player_id) == "t"
			or player_id == get_tree().get_network_unique_id()
			or not world_state_buffer[0].has(player_id)
		):
			continue
		if player_id in players_dict:
			var position_delta = (
				world_state_buffer[1][player_id].p
				- world_state_buffer[0][player_id].p
			)
			var position = (
				world_state_buffer[1][player_id].p
				+ (position_delta * extrapolation_factor)
			)
			players_dict[player_id].move_player(position)
