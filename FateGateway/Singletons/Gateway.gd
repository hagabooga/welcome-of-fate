extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var max_players = 100

var cert = load("res://Certificate/X509Certificate.crt")
var key = load("res://Certificate/X509Key.key")


func _ready():
	start_server()


func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_server():
	network.use_dtls = true
	network.set_dtls_certificate(cert)
	network.set_dtls_key(key)
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


func return_create_account_request(player_id, result):
	rpc_id(player_id, "return_create_account_request", result)
	network.disconnect_peer(player_id)


func return_login_request(result, player_id, token):
	rpc_id(player_id, "return_login_request", result, token)
	network.disconnect_peer(player_id)


remote func create_account_request(username, password):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	var bad = username == "" or password == "" or password.length() <= 6
	if bad:
		return_create_account_request(player_id, FAILED)
	else:
		Authenticate.create_account(player_id, username.to_lower(), password)

remote func login_request(username, password):
	print("login request recieved")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.authenticate_player(username, password, player_id)
