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


remote func authentication_results(result, player_id):
	print("Results recieved and replying to player login request")
	Gateway.return_login_request(result, player_id)
