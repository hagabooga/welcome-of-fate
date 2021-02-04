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
	var result = true
	print("Starting authentication...")
	if not PlayerData.data.has(username):
		print("User not recognized")
		result = false
	elif not PlayerData.data[username].password == password:
		print("Incorrect password")
		result = false
	else:
		print("Successful authentication")
	print("Authentication result send to gateway server.")
	rpc_id(gateway_id, "authentication_results", result, player_id)

# remote func fetch_skill(skill_name, requester):
# 	var player_id = get_tree().get_rpc_sender_id()
# 	var skill = ServerData.get_skill(skill_name)
# 	rpc_id(player_id, "return_skill", skill, requester)
# 	print("Sending " + str(skill) + " to player.")
