extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5


func _ready():
	start_server()


func start_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication Server Started")

	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected.")


func _peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected.")


remote func authenticate_player(username, password, player_id):
	print("Authentication request recieved")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = OK
	var token = null
	print("Starting authentication...")
	if not AccountDatabase.exists(username):
		print("User not recognized")
		result = FAILED
	elif not AccountDatabase.get(username).password == password:
		print("Incorrect password")
		result = FAILED
	else:
		print("Successful authentication")
		randomize()
		var hashed = str(randi()).sha256_text()
		var time_stamp = str(OS.get_unix_time())
		token = hashed + time_stamp
		print(token)
		var server = "server1"  # Replace with load balancers
		Servers.distribute_login_token(token, server)
	print(username, ": authentication results now sending to gateway server.")
	rpc_id(gateway_id, "authentication_results", result, player_id, token)

remote func create_account(player_id, username, password):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = OK
	if AccountDatabase.exists(username):
		result = ERR_ALREADY_EXISTS
	else:
		AccountDatabase.create(username, password)
	rpc_id(gateway_id, "create_account_results", player_id, result)
