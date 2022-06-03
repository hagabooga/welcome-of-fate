class_name AccountCreation
extends Node

var database: Database
var state_processing: StateProcessing
var player_verification: PlayerVerification


func _init(
	database: Database, state_processing: StateProcessing, player_verification: PlayerVerification
):
	self.database = database
	self.state_processing = state_processing
	self.player_verification = player_verification


remote func receive_request_create_account(data):
	var player_id = get_tree().get_rpc_sender_id()
	data.username = state_processing.connected_players[player_id]
	database.player_basics.insert(data)
	player_verification.return_token_verification_results(player_id, OK, data.username)
