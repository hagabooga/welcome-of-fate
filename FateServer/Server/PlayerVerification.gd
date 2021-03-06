class_name PlayerVerification
extends Node

var database: Database
var state_processing: StateProcessing
var network: NetworkedMultiplayerENet
var awaiting_verification := {}
var expected_tokens := {}

var verification_expiration: Timer
var token_expiration_timer: Timer

var map


func _init(database: Database, state_processing: StateProcessing, network: NetworkedMultiplayerENet):
	self.map = map
	self.database = database
	self.state_processing = state_processing
	self.network = network
	name = "PlayerVerification"
	verification_expiration = Timer.new()
	verification_expiration.autostart = true
	verification_expiration.name = "VerificationExpiration"
	add_child(verification_expiration)
	token_expiration_timer = Timer.new()
	token_expiration_timer.autostart = true
	token_expiration_timer.name = "TokenExpiration"
	add_child(token_expiration_timer)
	verification_expiration.connect("timeout", self, "on_verification_expireation_timeout")
	token_expiration_timer.connect("timeout", self, "on_token_expiration_timeout")


func start(player_id):
	awaiting_verification[player_id] = {"time_stamp": OS.get_unix_time()}
	rpc_id(player_id, "fetch_token")


func return_token_verification_results(player_id, result, username):
	if result == OK:
		state_processing.connected_players[player_id] = username
		print("SPAWNING PLAYER: ", username)
		# INFO NEEDS TO BE GET FROM DATABASE
		print(username)
		var basic = database.player_basics.select(username)
		var scene_to_load = Enums.SCENE_TEST_MAP
		print(basic)
		if not basic:
			scene_to_load = Enums.SCENE_CREATE_CHARACTER
			rpc_id(
				player_id,
				"return_token_verification_results",
				ERR_DOES_NOT_EXIST,
				state_processing.logged_in_players,
				scene_to_load
			)
		else:
			basic.loc = Vector2.ONE * (randi() % 100 - 50)
			spawn_player(player_id, database.player_basics.select(username), result)
	else:
		rpc_id(player_id, "return_token_verification_results", result, null)


func spawn_player(player_id, data, result):
	state_processing.logged_in_players[player_id] = {}
	state_processing.logged_in_players[player_id].basic = data
	var stats = database.player_stats.select(data.username)
	if not stats:
		var test_data = {}
		test_data.username = data.username
		test_data.str = 4
		test_data.int = 4
		test_data.agi = 4
		test_data.luc = 4
		database.player_stats.insert(test_data)
	state_processing.logged_in_players[player_id].stats = database.player_stats.select(
		data.username
	)
	# Give this new player logged in to all other players
	rpc_id(
		0, "receive_new_player_logged_in", player_id, state_processing.logged_in_players[player_id]
	)
	# Give already logged in players to player 
	print("state", state_processing.player_states)
	rpc_id(
		player_id,
		"return_token_verification_results",
		result,
		state_processing.logged_in_players,
		Enums.SCENE_TEST_MAP
	)
	
	state_processing.map.spawn_player(
		player_id, Vector2.ZERO, database.player_stats.select(data.username)
	)


func verify(player_id, token):
	var result = FAILED
	var username
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if token in expected_tokens:
			result = OK
			print(player_id, " success verification")
			# create player container
			username = expected_tokens[token]
			awaiting_verification.erase(player_id)
			expected_tokens.erase(token)
			break
		yield(get_tree().create_timer(2), "timeout")
	return_token_verification_results(player_id, result, username)
	if result != OK:  # Make sure people are disconnected
		awaiting_verification.erase(player_id)
		network.disconnect_peer(player_id)


func on_verification_expireation_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification:
			start_time = awaiting_verification[key].time_stamp
			if current_time - start_time >= 30:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if key in connected_peers:
					return_token_verification_results(key, false, null)
					network.disconnect_peer(key)
	# print("awaiting verifications: ", awaiting_verification)


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


remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	verify(player_id, token)
	print("verifying: ", player_id, " with token: ", token)

remote func receive_create_account_request(data):
	var player_id = get_tree().get_rpc_sender_id()
	data.username = state_processing.connected_players[player_id]
	database.player_basics.insert(data)
	var basic = database.player_basics.get(data.username)
	spawn_player(player_id, basic, OK)

remote func client_ready():
	var player_id = get_tree().get_rpc_sender_id()
	yield(get_tree().create_timer(0.0001), "timeout")
	var stats = database.player_stats.select(state_processing.connected_players[player_id])
	stats.loc = Vector2.ZERO
	rpc_id(0, "spawn_player", player_id)
