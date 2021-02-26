extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1915
var max_players = 100

var servers = {}


func _process(delta):
	if custom_multiplayer == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func _ready():
	print("ASKDAPOM")
	network.create_server(port, max_players)
	custom_multiplayer = gateway_api
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.network_peer = network
	print("Server Hub started")

	network.connect("peer_connected", self, "peer_connected")
	network.connect("peer_disconnected", self, "peer_disconnected")


func peer_connected(server_id):
	print("Server" + str(server_id) + " connected.")
	servers["server1"] = server_id
	print(servers)


func peer_disconnected(server_id):
	print("Server" + str(server_id) + " disconnected.")


func distribute_login_token(token, server):
	var server_id = servers[server]
	rpc_id(server_id, "receive_login_token", token)
