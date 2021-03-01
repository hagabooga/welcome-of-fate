extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var player_state_dict = {}

var logged_in_players = {}

#id to username
var connected_players = {}

# token : basic_player_info
var expected_tokens = {}

onready var map = $Map
onready var token_expiration_timer = $TokenExpiration
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
	token_expiration_timer.connect("timeout", self, "on_token_expiration_timeout")


func on_token_expiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens.size() == 0:
		pass
	else:
		for token in expected_tokens.keys():
			token_time = int(token.right(64))
			if current_time - token_time >= 30:
				expected_tokens.erase(token)
		# for i in range(expected_tokens.size() - 1, -1, -1):
		# 	token_time = int(expected_tokens[i].right(64))
		# 	if current_time - token_time >= 30:
		# 		expected_tokens.remove(i)
	# print("Expected tokens: ", expected_tokens)


func peer_connected(player_id):
	print("User " + str(player_id) + " connected.")
	PlayerVerification.start(player_id)


func peer_disconnected(player_id):
	var str_player_id = str(player_id)
	print("User " + str_player_id + " disconnected.")
	if player_id in logged_in_players:
		logged_in_players.erase(player_id)

	if player_state_dict.has(player_id):
		player_state_dict.erase(player_id)
		rpc_id(0, "despawn_player", player_id)

	if player_id in connected_players:
		connected_players.erase(player_id)


func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")


func return_token_verification_results(player_id, result, username):
	if result == OK:
		connected_players[player_id] = username
		print("SPAWNING PLAYER: ", username)
		# INFO NEEDS TO BE GET FROM DATABASE
		var basic = Database.players.get_basic(username)
		var scene_to_load = Enums.SCENE_TEST_MAP
		if basic == null:
			scene_to_load = Enums.SCENE_CREATE_CHARACTER
			rpc_id(
				player_id,
				"return_token_verification_results",
				ERR_DOES_NOT_EXIST,
				logged_in_players,
				scene_to_load
			)
		else:
			spawn_player(player_id, Database.players.get_basic(username), result)
	else:
		rpc_id(player_id, "return_token_verification_results", result, null)


func spawn_player(player_id, data, result):
	logged_in_players[player_id] = data
	# Give this new player logged in to all other players
	rpc_id(0, "receive_new_player_logged_in", player_id, data)
	# Give already logged in players to player 
	rpc_id(
		player_id,
		"return_token_verification_results",
		result,
		logged_in_players,
		Enums.SCENE_TEST_MAP
	)


remote func client_ready():
	var player_id = get_tree().get_rpc_sender_id()
	yield(get_tree().create_timer(0.0001), "timeout")
	rpc_id(0, "spawn_player", player_id)


func send_world_state(world_state):
	rpc_unreliable_id(0, "receive_world_state", world_state)


remote func attack(position, direction_vector, animation_state, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	map.spawn_projectile(player_id, position, direction_vector, animation_state, spawn_time)
	rpc_id(0, "receive_attack", player_id, position, direction_vector, animation_state, spawn_time)

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

remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	PlayerVerification.verify(player_id, token)
	print("verifying: ", player_id, " with token: ", token)

remote func receive_create_account_request(data):
	var player_id = get_tree().get_rpc_sender_id()
	Database.players.create_basic(connected_players[player_id], data)
	var basic = Database.players.get_basic(connected_players[player_id])
	spawn_player(player_id, basic, OK)

remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_id in player_state_dict:
		if player_state_dict[player_id].t < player_state.t:
			player_state_dict[player_id] = player_state
	else:
		player_state_dict[player_id] = player_state

# remote func send_enemy_hit(enemy_id, damage):
# 	map.enemy_hit(enemy_id, damage)
