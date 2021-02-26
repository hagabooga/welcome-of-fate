extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var player_state_dict = {}
var player_info_dict = {}

onready var map = $Map
# onready var test_map = $ServerTestMap


# rpc_id(0, ...) calls function to all clients
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
	# Obtain player info
	# rpc_id(0, "return_basic_player_info", player_id, player_info_dict)


func peer_disconnected(player_id):
	var str_player_id = str(player_id)
	print("User " + str_player_id + " disconnected.")
	if player_state_dict.has(player_id):
		player_state_dict.erase(player_id)
		rpc_id(0, "despawn_player", player_id)


func send_world_state(world_state):
	rpc_unreliable_id(0, "receive_world_state", world_state)


remote func attack(position, direction_vector, animation_state, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	map.spawn_projectile(player_id, position, direction_vector, animation_state, spawn_time)
	rpc_id(0, "receive_attack", player_id, position, direction_vector, animation_state, spawn_time)

remote func create_new_account(username, color):
	var player_id = get_tree().get_rpc_sender_id()
	var player_from_database = Database.players.get_player(username)
	if player_from_database == null:
		Database.players.create_account(username, color)
		rpc_id(player_id, "receive_account_creation", OK)
	else:
		rpc_id(player_id, "receive_account_creation", FAILED)

remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)

remote func fetch_skill(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var skill = ServerData.get_skill(skill_name)
	rpc_id(player_id, "return_skill", skill, requester)
	print("Sending " + str(skill) + " to player.")

remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)

remote func login(username):
	var player_id = get_tree().get_rpc_sender_id()
	print(username)
	var player_from_database = Database.players.get_player(username)
	if player_from_database == null:
		rpc_id(0, "receive_login", player_id, null)
	else:
		player_from_database.n = player_from_database.ming
		player_from_database.c = player_from_database.color
		player_from_database.erase("ming")
		player_from_database.erase("color")
		player_from_database.loc = Vector2(randi() % 50, randi() % 50)
		player_info_dict[player_id] = player_from_database
		rpc_id(0, "receive_login", player_id, player_info_dict)
		rpc_id(0, "spawn_player", player_id, player_from_database)

remote func receive_basic_player_info(player_info):
	var player_id = get_tree().get_rpc_sender_id()
	player_info_dict[player_id] = player_info
	var player_from_database = Database.players.get_player(player_info.n)
	if player_from_database == null:
		Database.players.create_account(player_info.n, player_info.c)
	player_from_database = Database.players.get_player(player_info.n)
	player_from_database.n = player_from_database.ming
	player_from_database.c = player_from_database.color
	player_from_database.erase("ming")
	player_from_database.erase("color")
	rpc_id(0, "spawn_player", player_id, Vector2(randi() % 50, randi() % 50), player_from_database)

remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_id in player_state_dict:
		if player_state_dict[player_id].t < player_state.t:
			player_state_dict[player_id] = player_state
	else:
		player_state_dict[player_id] = player_state

# remote func send_enemy_hit(enemy_id, damage):
# 	map.enemy_hit(enemy_id, damage)
