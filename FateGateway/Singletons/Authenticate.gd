extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911


func _ready():
	connect_to_server()


func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_succeeded", self, "_connection_succeeded")
	network.connect("connection_failed", self, "_connection_failed")


func _connection_succeeded():
	print("Successfully connected to authentication server.")


func _connection_failed():
	print("Failed to connect to authentication server.")


func authenticate_player(username, password, player_id):
	print("sending out authentication request")
	rpc_id(1, "authenticate_player", username, password, player_id)


func create_account(player_id, username, password):
	print("Sending create account request")
	rpc_id(1, "create_account", player_id, username, password)


remote func authentication_results(result, player_id, token):
	print("Results recieved and replying to player login request")
	Gateway.return_login_request(result, player_id, token)

remote func create_account_results(player_id, result):
	Gateway.return_create_account_request(player_id, result)
