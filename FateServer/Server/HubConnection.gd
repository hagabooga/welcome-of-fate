class_name HubConnection
extends Node

var player_verification: PlayerVerification
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()

var ip = "127.0.0.1"
var port = 1915


func _init(player_verification):
	self.player_verification = player_verification
	network.create_client(ip, port)
	custom_multiplayer = gateway_api
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.network_peer = network

	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")


func _process(delta):
	if custom_multiplayer == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func connection_succeeded():
	print("Successfully connected to SERVER HUB")


func connection_failed():
	print("Unable to connect to SERVER HUB")


remote func receive_login_token(token, username):
	player_verification.expected_tokens[token] = username
