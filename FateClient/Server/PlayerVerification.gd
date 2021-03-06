class_name PlayerVerification
extends Node

var clock: Clock
var database: Database
var state_processing: StateProcessing


func _init(clock: Clock, database: Database, state_processing: StateProcessing):
	self.clock = clock
	self.database = database
	self.state_processing = state_processing
	name = "PlayerVerification"


remote func fetch_token():
	rpc_id(1, "return_token", database.token)

remote func receive_new_player_logged_in(player_id, info):
	state_processing.logged_in_players[player_id] = info

remote func return_token_verification_results(result, logged_in_players, scene_to_load):
	match result:
		OK:  # Enter map
			# delete login screen
			print("WE IN BOIZ")
			state_processing.logged_in_players = logged_in_players
			var map = database.preloaded_scenes[scene_to_load].instance()
			map.init(clock, state_processing)
			get_tree().get_root().add_child(map)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = map
			# get_tree().change_scene_to(database.preloaded_scenes[scene_to_load])
			print("okok")
			rpc_id(1, "client_ready")
		FAILED:
			# try again
			print("try again")
		ERR_DOES_NOT_EXIST:
			# new account
			print("account creation")
			# get_tree().change_scene_to(preloaded_scenes[scene_to_load])
			state_processing.logged_in_players = logged_in_players


func send_account_request(data):
	rpc_id(1, "receive_create_account_request", data)


remote func spawn_player(player_id):
	get_tree().current_scene.spawn_player(player_id, null)
	if player_id == get_tree().get_network_unique_id():
		state_processing.in_map = true
	# print("spawning player ", player_id, spawn_position)
