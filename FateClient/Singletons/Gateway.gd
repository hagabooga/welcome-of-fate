# extends Node

# var network = NetworkedMultiplayerENet.new()
# var gateway_api = MultiplayerAPI.new()
# var ip = "127.0.0.1"
# var port = 1910

# var username
# var password

# func _ready():
# 	pass

# func _process(delta):
# 	if custom_multiplayer == null:
# 		return
# 	if not custom_multiplayer.has_network_peer():
# 		return
# 	custom_multiplayer.poll()

# func connect_to_server(username, password):
# 	network = NetworkedMultiplayerENet.new()
# 	gateway_api = MultiplayerAPI.new()
# 	self.username = username
# 	self.password = password
# 	network.create_client(ip, port)
# 	custom_multiplayer = gateway_api
# 	custom_multiplayer.set_root_node(self)
# 	custom_multiplayer.network_peer = network

# 	network.connect("connection_succeeded", self, "_connection_succeeded")
# 	network.connect("connection_failed", self, "_connection_failed")

# func _connection_succeeded():
# 	print("Successfully connected to the login server.")
# 	request_login()

# func _connection_failed():
# 	print("Failed to connect to login server.")
# 	print("Pop-ip server offline or something")

# func request_login():
# 	print("Connecting to gateway to request login")
# 	rpc_id(1, "login_request", username, password)
# 	username = ""
# 	password = ""

# remote func return_login_request(result):
# 	print("Results recieved")
# 	if result == true:
# 		Server.connect_to_server()
# 		print("DELETE LOGIN SCREEN")
# 	else:
# 		print("Please provide correct username and password")
# 	network.disconnect("connection_succeeded", self, "_connection_succeeded")
# 	network.disconnect("connection_failed", self, "_connection_failed")
