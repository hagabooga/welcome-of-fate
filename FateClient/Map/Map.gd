extends Node2D

# Change based on geography (bigger more lag but smoother?)
const INTERPOLATION_OFFSET = 100

var players_dict = {}
var last_world_state = 0
var world_state_buffer = []

onready var player_actual = preload("res://Entity/Player/Player.tscn")
onready var player_template = preload("res://Entity/Player/PlayerTemplate.tscn")
onready var players = $Objects/Players
onready var enemies_node = $Objects/Enemies

onready var worm = preload("res://Entity/Enemy/SmallWorm/SmallWorm.tscn")

var enemies = {}


func erase_enemy(id):
	enemies.erase(id)


func _physics_process(delta):
	var render_time = Server.client_clock - INTERPOLATION_OFFSET
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


func spawn_enemy(enemy_id, enemy_data):
	if not Server.logged_in:
		return
	var enemy = worm.instance()
	enemy.init(enemy_data)
	enemy.id = enemy_id
	enemy.position = enemy_data.loc
	enemies_node.add_child(enemy)
	enemies[enemy_id] = enemy


func spawn_player(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id and not player_id in players_dict:
		# The client user 
		#print("Spawning client user")
		instance_player(player_id, spawn_position, player_actual)
	else:
		# Spawn other players
		if not player_id in players_dict:
			#print("spawning ", player_id)
			instance_player(player_id, spawn_position, player_template)


func instance_player(player_id, spawn_position, scene):
	var player = scene.instance()
	if scene == player_actual:
		pass
		# player.set_script(load("res://Entity/Mage.gd"))
	var basic = AllPlayersInfo.basics[player_id]
	player.init(player_id, spawn_position, basic)
	players.add_child(player)
	players_dict[player_id] = player


func despawn_player(player_id):
	#print("despawning ", player_id)
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
			str(player_id) in ["t", "enemies"]
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
			var animation_data = world_state_buffer[2][player_id].a
			players_dict[player_id].move_player(position, animation_data)
		else:
			spawn_player(player_id, world_state_buffer[2][player_id].p)
	for enemy_id in world_state_buffer[2].enemies:
		if not enemy_id in world_state_buffer[1].enemies:
			continue
		if enemy_id in enemies:
			var new_position = lerp(
				world_state_buffer[1].enemies[enemy_id].loc,
				world_state_buffer[2].enemies[enemy_id].loc,
				interpolation_factor
			)
			# move enemy and add health
			if enemies[enemy_id].hp > 0:
				if enemies[enemy_id].hp != world_state_buffer[1].enemies[enemy_id].hp:
					enemies[enemy_id].hp = world_state_buffer[1].enemies[enemy_id].hp
		else:
			if world_state_buffer[2].enemies[enemy_id].hp > 0:
				#print("spawning enemy in interpolation... ")
				spawn_enemy(enemy_id, world_state_buffer[2].enemies[enemy_id])


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
			str(player_id) in ["t", "enemies"]
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
			var animation_data = world_state_buffer[1][player_id].a
			players_dict[player_id].move_player(position, animation_data)
