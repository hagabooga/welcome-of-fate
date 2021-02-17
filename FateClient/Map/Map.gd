extends Node2D

var player_actual = preload("res://Player/Player.tscn")
var player_template = preload("res://Player/PlayerTemplate.tscn")

onready var players = $Objects/Players
var players_dict = {}

var last_world_state = 0
var world_state_buffer = []

# Change based on geography (bigger more lag but smoother?)
const INTERPOLATION_OFFSET = 100


func _ready():
	players.add_child(player_actual.instance())


# func _process(delta):
# 	if Input.is_action_just_pressed("ui_accept"):
# 		print(players_dict)


func spawn_player(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		# The client user 
		print("Spawning client user")
	else:
		# Spawn other players
		if not player_id in players_dict:
			print("spawning ", player_id)
			var new_player = player_template.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			players.add_child(new_player)
			players_dict[player_id] = new_player


func despawn_player(player_id):
	print("despawning ", player_id)
	players_dict[player_id].queue_free()
	players_dict.erase(player_id)
	for world_state in world_state_buffer:
		if player_id in world_state:
			world_state.erase(player_id)


# world_state: t=time, p=position
# world_state_buffer = [most_recent_past, nearest_future, any_other_future]
func _physics_process(delta):
	var render_time = OS.get_system_time_msecs() - INTERPOLATION_OFFSET
	# print(world_state_buffer)
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1].t:
			world_state_buffer.remove(0)
		var interpolation_factor = (
			float(render_time - world_state_buffer[0].t)
			/ float(world_state_buffer[1].t - world_state_buffer[0].t)
		)
		for player_id in world_state_buffer[1]:
			if str(player_id) == "t":
				continue
			if player_id == get_tree().get_network_unique_id():
				continue
			if not world_state_buffer[0].has(player_id):
				continue
			if player_id in players_dict:
				var position = lerp(
					world_state_buffer[0][player_id].p,
					world_state_buffer[1][player_id].p,
					interpolation_factor
				)
				players_dict[player_id].move_player(position)
			else:
				spawn_player(player_id, world_state_buffer[1][player_id].p)


func update_world_state(world_state):
	if world_state.t > last_world_state:
		last_world_state = world_state.t
		world_state_buffer.append(world_state)
