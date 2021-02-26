extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()

var ip = "127.0.0.1"
var port = 1915

onready var server = get_tree().current_scene


func _process(delta):
	if custom_multiplayer == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func _ready():
	print("OKOK")
	network.create_client(ip, port)
	custom_multiplayer = gateway_api
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.network_peer = network

	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")


func connection_succeeded():
	print("Successfully connected to SERVER HUB")


func connection_failed():
	print("Unable to connect to SERVER HUB")


remote func receive_login_token(token):
	server.expected_tokens.append(token)
