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
var server


func erase_enemy(id):
	enemies.erase(id)


func _physics_process(delta):
	var render_time = server.client_clock - INTERPOLATION_OFFSET
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
	var enemy = worm.instance()
	enemy.init(enemy_data)
	enemy.id = enemy_id
	enemy.global_position = enemy_data.p
	enemies_node.add_child(enemy)
	enemies[enemy_id] = enemy


func spawn_player(player_id, stats, loc = null):
	if loc != null:
		if not player_id in server.logged_in_players:
			return
		server.logged_in_players[player_id].basic.loc = loc
	if get_tree().get_network_unique_id() == player_id and not player_id in players_dict:
		# The client user 
		#print("Spawning client user")
		instance_player(player_id, stats, player_actual)
	else:
		# Spawn other players
		if not player_id in players_dict:
			#print("spawning ", player_id)
			instance_player(player_id, stats, player_template)


func instance_player(player_id, stats, scene):
	var player = scene.instance()
	if scene == player_actual:
		pass
	var basic_info = server.logged_in_players[player_id].basic
	player.init(
		player_id,
		basic_info.loc,
		BasicPlayerInfo.new(basic_info, Color.white),
		server.logged_in_players[player_id].stats
	)
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
	# Player
	for player_id in world_state_buffer[2]:
		if str(player_id) in ["t", "enemies"] or not world_state_buffer[0].has(player_id):
			continue
		if player_id == get_tree().get_network_unique_id():
			if players_dict[player_id].hp > 0:
				players_dict[player_id].hp = world_state_buffer[2][player_id].hp
			continue
		if player_id in players_dict:
			var position = lerp(
				world_state_buffer[1][player_id].p,
				world_state_buffer[2][player_id].p,
				interpolation_factor
			)
			var animation_data = world_state_buffer[2][player_id].a
			if players_dict[player_id].hp > 0:
				players_dict[player_id].hp = world_state_buffer[2][player_id].hp
			players_dict[player_id].move_player(position, animation_data)
		else:
			var stats = {}
			stats.hp = world_state_buffer[2][player_id].hp
			stats.loc = world_state_buffer[2][player_id].p
			spawn_player(player_id, stats)
	# Enemy
	for enemy_id in world_state_buffer[2].enemies:
		if not enemy_id in world_state_buffer[1].enemies:
			continue
		if enemy_id in enemies:
			var new_position = lerp(
				world_state_buffer[1].enemies[enemy_id].p,
				world_state_buffer[2].enemies[enemy_id].p,
				interpolation_factor
			)
			# move enemy and add health
			var move_dir = world_state_buffer[2].enemies[enemy_id].d
			var anim = world_state_buffer[2].enemies[enemy_id].a
			enemies[enemy_id].move_enemy(new_position, move_dir, anim)
			if enemies[enemy_id].hp > 0:
				if enemies[enemy_id].hp != world_state_buffer[2].enemies[enemy_id].hp:
					enemies[enemy_id].hp = world_state_buffer[2].enemies[enemy_id].hp
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
	# Player
	for player_id in world_state_buffer[1]:
		if str(player_id) in ["t", "enemies"] or not world_state_buffer[0].has(player_id):
			continue
		if player_id == get_tree().get_network_unique_id():
			if players_dict[player_id].hp > 0:
				players_dict[player_id].hp = world_state_buffer[1][player_id].hp
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
			if players_dict[player_id].hp > 0:
				players_dict[player_id].hp = world_state_buffer[1][player_id].hp
			players_dict[player_id].move_player(position, animation_data)

	# Enemy
	for enemy_id in world_state_buffer[1].enemies:
		if not enemy_id in world_state_buffer[0].enemies:
			continue

		if enemy_id in enemies:
			var position_delta = (
				world_state_buffer[1].enemies[enemy_id].p
				- world_state_buffer[0].enemies[enemy_id].p
			)
			var position = (
				world_state_buffer[1].enemies[enemy_id].p
				+ (position_delta * extrapolation_factor)
			)
			var move_dir = world_state_buffer[1].enemies[enemy_id].d
			var anim = world_state_buffer[1].enemies[enemy_id].a
			enemies[enemy_id].move_enemy(position, move_dir, anim)
