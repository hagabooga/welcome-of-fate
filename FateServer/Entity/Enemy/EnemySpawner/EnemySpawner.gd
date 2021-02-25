extends Node

export (PoolStringArray) var enemy_names
export (int) var enemy_maximum = 5

var enemy_count = 0
var open_locations = []
var occupied_locations = {}
var enemies = {}

onready var spawn_locations = $SpawnLocations
onready var timer = $Timer

# func _ready():
# 	timer.connect("timeout", self, "spawn_enemy")
# 	open_locations = range(spawn_locations.get_child_count())
# 	print(open_locations)


func spawn_enemy():
	if enemies.size() < enemy_maximum:
		randomize()
		var enemy = enemy_names[randi() % enemy_names.size()]
		var random_location_index = randi() % open_locations.size()
		var location = spawn_locations.get_child(open_locations[random_location_index])
		occupied_locations[enemy_count] = open_locations[random_location_index]
		open_locations.remove(random_location_index)
		enemies[enemy_count] = "Worm"  # Worm Stats
		enemy_count += 1
	for key in enemies:
		var enemy = enemies[key]
		print(enemy)
		# if enemy.state == "Dead":
		# 	if enemy.time_out == 0:
		# 		enemies.erase(key)
		# 	else:
		# 		enemy.time_out -= 1
