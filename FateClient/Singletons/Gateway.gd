extends Node

signal recieved_login_request(result, token)

var network
var gateway_api
# var ip = "127.0.0.1"
var port = 1910

var username
var password


func _ready():
	pass


func _process(delta):
	if custom_multiplayer == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func connect_to_server(login_screen, username, password, ip = "127.0.0.1"):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	self.username = username
	self.password = password
	network.create_client(ip, port)
	custom_multiplayer = gateway_api
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.network_peer = network

	if not is_connected("recieved_login_request", login_screen, "on_login_received"):
		connect("recieved_login_request", login_screen, "on_login_received")
	if not network.is_connected("connection_failed", login_screen, "on_failed_connect_to_server"):
		network.connect("connection_failed", login_screen, "on_failed_connect_to_server")
	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")


func connection_succeeded():
	print("Successfully connected to the login server.")
	request_login()


func connection_failed():
	print("Failed to connect to login server.")
	print("Pop-ip server offline or something")


func request_login():
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""


remote func return_login_request(result, token):
	emit_signal("recieved_login_request", result, token)
	network.disconnect("connection_succeeded", self, "connection_succeeded")
	network.disconnect("connection_failed", self, "connection_failed")
