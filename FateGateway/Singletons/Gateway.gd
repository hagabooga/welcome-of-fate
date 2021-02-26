extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var max_players = 100


func _ready():
	start_server()


func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_server():
	network.create_server(port, max_players)
	custom_multiplayer = gateway_api
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.network_peer = network
	print("Gateway server Started")

	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(player_id):
	print("User " + str(player_id) + " connected.")


func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected.")


remote func login_request(username, password):
	print("login request recieved")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.authenticate_player(username, password, player_id)


func return_login_request(result, player_id, token):
	rpc_id(player_id, "return_login_request", result, token)
	network.disconnect_peer(player_id)
