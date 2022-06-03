class_name StateProcessing
extends Node

# { player_id: username }
var connected_players := {}

# { player_id: { basic, stats } }
var logged_in_players := {}

var world_state := {}
var player_states := {}

var map
var database: Database

var sync_clock_counter := 0


func _init(map, database: Database):
	self.map = map
	self.database = database


func _physics_process(delta):
	sync_clock_counter += 1
	if sync_clock_counter != 3:
		return
	sync_clock_counter = 0
	# print(player_states)
	if not player_states.empty():
		world_state = player_states.duplicate(true)
		for player_id in world_state:
			world_state[player_id].erase("t")
		world_state.t = OS.get_system_time_msecs()
		# print(world_state)
		world_state.enemies = map.enemy_datas
		# Verifications
		# Anti-Cheat
		# Cuts
		# Physics checks
		# Anything else you have to do
		rpc_unreliable_id(0, "receive_world_state", world_state)


func player_disconnected(player_id: int):
	rpc_id(0, "player_disconnected", player_id)


func despawn_player(player_id: int):
	rpc_id(0, "despawn_player", player_id)


remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	# print(player_state)
	if player_id in player_states:
		if player_states[player_id].t < player_state.t:
			player_states[player_id] = player_state
	else:
		player_states[player_id] = player_state
