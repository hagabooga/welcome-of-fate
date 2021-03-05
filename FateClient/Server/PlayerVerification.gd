class_name PlayerVerification
extends Node

var server_data: ServerData


func _init(server_data):
	self.server_data = server_data
	name = "PlayerVerification"


remote func fetch_token():
	rpc_id(1, "return_token", server_data.token)

remote func receive_new_player_logged_in(player_id, info):
	server_data.logged_in_players[player_id] = info

remote func return_token_verification_results(result, logged_in_players, scene_to_load):
	match result:
		OK:  # Enter map
			# delete login screen
			print("WE IN BOIZ")
			server_data.logged_in_players = logged_in_players
			# get_tree().change_scene_to(preloaded_scenes[scene_to_load])
			rpc_id(1, "client_ready")
		FAILED:
			# try again
			print("try again")
		ERR_DOES_NOT_EXIST:
			# new account
			print("account creation")
			# get_tree().change_scene_to(preloaded_scenes[scene_to_load])
			server_data.logged_in_players = logged_in_players
