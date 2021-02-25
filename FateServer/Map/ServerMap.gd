extends Node2D

onready var snake_bite = preload("res://SupportScenes/ServerSnakeBite.tscn")
onready var small_worm = preload("res://SupportScenes/ServerSmallWorm.tscn")

onready var enemies_parent = $Objects/Enemies

var enemy_ids = [0]
var enemy_maximum = 3

var enemy_count = 0
var open_locations = []
var occupied_locations = {}
var enemy_datas = {}
var enemy_objects = {}

var spawn_locations = [Vector2(100, 100), Vector2(200, 50), Vector2(0, 100)]


func _ready():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 3
	timer.connect("timeout", self, "spawn_enemy")
	add_child(timer)
	open_locations = range(spawn_locations.size())


func spawn_enemy():
	print(enemy_datas)
	if enemy_datas.size() < spawn_locations.size() and open_locations.size() > 0:
		randomize()
		print(open_locations)
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


func enemy_hit(enemy_id, damage):
	var enemy = enemy_datas[enemy_id]
	if enemy.hp > 0:
		enemy.hp -= damage
		if enemy.hp <= 0:
			enemy_objects[enemy_id].queue_free()
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
	enemy_datas[enemy_id] = Database.enemies.get_enemy(enemy.id)
	enemy_datas[enemy_id].loc = location
	enemy_datas[enemy_id].time_out = 1
	# enemy.init(enemy_id, location)
	enemy.position = location
	enemy.name = str(enemy_id)
	enemy.set_meta("id", enemy_id)
	enemies_parent.add_child(enemy, true)
