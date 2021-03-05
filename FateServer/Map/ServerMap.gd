extends Node2D

onready var snake_bite = preload("res://SupportScenes/ServerSnakeBite.tscn")
onready var small_worm = preload("res://SupportScenes/ServerSmallWorm.tscn")

onready var enemies_parent = $Objects/Enemies
onready var players_parent = $Objects/Players

var enemy_ids = [0]
var enemy_maximum = 3

var enemy_count = 0
var open_locations = []
var occupied_locations = {}
var enemy_datas = {}
var enemy_objects = {}

var player_objects = {}

var spawn_locations = [Vector2(100, 100), Vector2(200, 50), Vector2(0, 100)]

onready var server_player = preload("res://SupportScenes/ServerPlayer.tscn")

var database: Database
var state_processing: StateProcessing


func init(database: Database, state_processing: StateProcessing, network: NetworkedMultiplayerENet):
	self.database = database
	self.state_processing = state_processing
	network.connect("peer_disconnected", self, "despawn_player")


func _ready():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 3
	timer.connect("timeout", self, "spawn_enemy")
	add_child(timer)
	open_locations = range(spawn_locations.size())


func _process(delta):
	for player_id in state_processing.player_states.keys():
		player_objects[player_id].global_position = state_processing.player_states[player_id].p
		state_processing.player_states[player_id].hp = player_objects[player_id].hp
	for enemy_id in enemy_datas:
		if enemy_datas[enemy_id].hp > 0:
			enemy_datas[enemy_id].p = enemy_objects[enemy_id].global_position
			enemy_datas[enemy_id].d = enemy_objects[enemy_id].move_direction
			enemy_datas[enemy_id].a = enemy_objects[enemy_id].current_animation


func despawn_player(player_id):
	player_objects[player_id].queue_free()
	player_objects.erase(player_id)


func spawn_player(player_id, loc, data):
	var player = server_player.instance()
	player.init(player_id, loc, data)
	player_objects[player_id] = player
	players_parent.add_child(player)


func spawn_enemy():
	# print(enemy_datas)
	if enemy_datas.size() < spawn_locations.size() and open_locations.size() > 0:
		randomize()
		# print(open_locations)
		var enemy_id = enemy_ids[randi() % enemy_ids.size()]
		var random_location_index = randi() % open_locations.size()
		var location = spawn_locations[open_locations[random_location_index]]
		location += (Vector2.ONE * (randi() % 50))
		occupied_locations[enemy_count] = open_locations[random_location_index]
		open_locations.remove(random_location_index)
		instance_enemy(enemy_count, location)
		enemy_count += 1
	# print(enemies)
	for key in enemy_datas:
		var enemy = enemy_datas[key]
		if enemy == null:
			continue
		if enemy.hp <= 0:  # == "Dead":
			if enemy.time_out == 0:
				enemy_datas.erase(key)
			else:
				enemy.time_out -= 1


func player_hit(player_id, enemy_id):
	print("HIT")
	player_objects[player_id].hp -= 10
	if player_objects[player_id].hp <= 0:
		player_objects[player_id].die()
		enemy_objects[enemy_id].in_attack_range = false
		# player_objects[player_id].queue_free()
		# player_objects.erase(player_id)


func enemy_hit(player_id, enemy_id, damage):
	var enemy = enemy_datas[enemy_id]
	if enemy.hp > 0:
		enemy_objects[enemy_id].current_target = player_objects[player_id]
		enemy.hp -= damage
		if enemy.hp <= 0:
			enemy_objects[enemy_id].queue_free()
			enemy_objects.erase(enemy_id)
			# enemies.erase(enemy_id)
			# now dead
			# enemies.enemy.state = "dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)


func spawn_projectile(player_id, position, direction_vector, animation_state, spawn_time):
	var proj = snake_bite.instance()
	proj.player_id = player_id
	proj.global_position = position
	proj.direction_vector = direction_vector
	proj.direction = animation_state.f
	add_child(proj)


func instance_enemy(enemy_id, location):
	var enemy = small_worm.instance()
	enemy_objects[enemy_id] = enemy
	enemy_datas[enemy_id] = database.enemies.select(enemy.id)
	enemy_datas[enemy_id].max_hp = enemy_datas[enemy_id].hp
	enemy_datas[enemy_id].p = location
	enemy_datas[enemy_id].time_out = 1
	enemy_datas[enemy_id].id = enemy_id

	enemy.init(self, location, enemy_id)

	enemies_parent.add_child(enemy, true)
