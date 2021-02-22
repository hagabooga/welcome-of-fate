extends Node

var world_state = {}

onready var server = get_parent()
onready var map = get_parent().find_node("Map")

var sync_clock_counter = 0


func _physics_process(delta):
	sync_clock_counter += 1
	if sync_clock_counter != 3:
		return
	sync_clock_counter = 0
	if not server.player_state_dict.empty():
		world_state = server.player_state_dict.duplicate(true)
		for player_id in world_state:
			world_state[player_id].erase("t")
		world_state.t = OS.get_system_time_msecs()
		world_state.enemies = map.enemies
		# Verifications
		# Anti-Cheat
		# Cuts
		# Physics checks
		# Anything else you have to do
		server.send_world_state(world_state)
