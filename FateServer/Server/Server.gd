extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var peers_dict = {}
var player_state_dict = {}


func _ready():
	start_server()


func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")

	network.connect("peer_connected", self, "peer_connected")
	network.connect("peer_disconnected", self, "peer_disconnected")


func peer_connected(player_id):
	print("User " + str(player_id) + " connected.")
	rpc_id(0, "spawn_new_player", player_id, Vector2(100, 100))


func peer_disconnected(player_id):
	var str_player_id = str(player_id)
	print("User " + str_player_id + " disconnected.")
	if player_state_dict.has(player_id):
		player_state_dict.erase(player_id)
		rpc_id(0, "despawn_player", player_id)


func send_world_state(world_state):
	rpc_unreliable_id(0, "recieve_world_state", world_state)


remote func fetch_skill(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var skill = ServerData.get_skill(skill_name)
	rpc_id(player_id, "return_skill", skill, requester)
	print("Sending " + str(skill) + " to player.")

remote func recieve_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_id in player_state_dict:
		if player_state_dict[player_id].t < player_state.t:
			player_state_dict[player_id] = player_state
	else:
		player_state_dict[player_id] = player_state
