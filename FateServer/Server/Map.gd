extends Node

var enemy_names = ["SmallWorm"]
var enemy_maximum = 3

var enemy_count = 0
var open_locations = []
var occupied_locations = {}
var enemies = {}

var spawn_locations = [Vector2(100, 100), Vector2(200, 50), Vector2(0, 100)]


func _ready():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 3
	timer.connect("timeout", self, "spawn_enemy")
	add_child(timer)
	open_locations = range(spawn_locations.size())
	print("OK")
	# print(open_locations)


func spawn_enemy():
	if enemies.size() < spawn_locations.size() and open_locations.size() > 0:
		randomize()
		print(open_locations)
		var enemy = enemy_names[randi() % enemy_names.size()]
		var random_location_index = randi() % open_locations.size()
		var location = spawn_locations[open_locations[random_location_index]]
		occupied_locations[enemy_count] = open_locations[random_location_index]
		open_locations.remove(random_location_index)
		enemies[enemy_count] = {"ming": enemy, "loc": location + (Vector2.ONE * (randi()%50)), "hp": 100, "time_out": 1}
		enemy_count += 1
	print(enemies)
	for key in enemies:
		var enemy = enemies[key]
		if enemy.hp <= 0:  # == "Dead":
			if enemy.time_out == 0:
				enemies.erase(key)
			else:
				enemy.time_out -= 1


func enemy_hit(enemy_id, damage):
	var enemy = enemies[enemy_id]
	if enemy.hp > 0:
		enemy.hp -= damage
		if enemy.hp <= 0:
			# now dead
			# enemies.enemy.state = "dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)
