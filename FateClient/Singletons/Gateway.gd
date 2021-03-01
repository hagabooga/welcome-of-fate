extends Node

signal received_login_request(result, token)
signal received_account_request(result)

var network
var gateway_api
# var ip = "127.0.0.1"
var port = 1969

var username
var password
var new_account

var cert = load("res://Certificate/X509Certificate.crt")


func _ready():
	pass


func _process(delta):
	if custom_multiplayer == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func connect_to_server(login_screen, username, password, new_account = false, ip = "127.0.0.1"):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()

	network.use_dtls = true
	network.dtls_verify = false  # Set to true when using signed cert 
	network.set_dtls_certificate(cert)

	self.username = username
	self.password = password
	self.new_account = new_account
	network.create_client(ip, port)
	custom_multiplayer = gateway_api
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.network_peer = network

	if not is_connected("received_login_request", login_screen, "on_login_received"):
		connect("received_login_request", login_screen, "on_login_received")

	if not is_connected("received_account_request", login_screen, "on_received_account_request"):
		connect("received_account_request", login_screen, "on_received_account_request")

	network.connect("connection_failed", login_screen, "on_failed_connect_to_server")

	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")


func connection_succeeded():
	print("Successfully connected to the login server.")
	if new_account:
		request_create_account()
	else:
		request_login()


func connection_failed():
	print("Failed to connect to login server.")
	print("Pop-ip server offline or something")


func request_create_account():
	print("Requesting new account")
	rpc_id(1, "create_account_request", username, password.sha256_text())
	username = ""
	password = ""


func request_login():
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password.sha256_text())
	username = ""
	password = ""


remote func return_create_account_request(result):
	emit_signal("received_account_request", result)
	network.disconnect("connection_succeeded", self, "connection_succeeded")
	network.disconnect("connection_failed", self, "connection_failed")

remote func return_login_request(result, token):
	emit_signal("received_login_request", result, token)
	network.disconnect("connection_succeeded", self, "connection_succeeded")
	network.disconnect("connection_failed", self, "connection_failed")
