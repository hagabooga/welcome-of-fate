extends Node

signal account_creation_received(error)
signal login_received(error)

var network
var port = 1909

var waiting_for_connection = false
var successfully_connected = false

var client_clock = 0
var decimal_collector = 0
var latency_array = []
var latency = 0
var latency_delta = 0

var in_map = false
var token

var logged_in_players = {}

onready var preloaded_scenes = {
	Enums.SCENE_TEST_MAP: preload("res://Map/TestMap.tscn"),
	Enums.SCENE_CREATE_CHARACTER:
	preload("res://UI/CreateCharacterScreen/CreateCharacterScreen.tscn")
}


func _physics_process(delta):  #0.01667
	client_clock += int(delta * 1000) + latency_delta
	latency_delta = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00


func connect_to_server(enter_ip_screen, ip = "127.0.0.1"):
	# AllPlayersInfo.user_basic = BasicPlayerInfo.new(display_name, color)
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().network_peer = network
	network.connect("connection_succeeded", enter_ip_screen, "on_successful_connect_to_server")
	network.connect("connection_failed", enter_ip_screen, "on_failed_connect_to_server")
	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")
	waiting_for_connection = true


func connection_succeeded():
	waiting_for_connection = false
	successfully_connected = true
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	add_child(timer)
	print("Successfully connected.")


func connection_failed():
	print("Failed to connect.")


# Fetch from server
# Calls function on server
# server calls return method


func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())


func fetch_skill(skill_name, requester):
	rpc_id(1, "fetch_skill", skill_name, requester)


func send_new_character_data(data):
	rpc_id(1, "receive_create_account_request", data)


remote func fetch_token():
	rpc_id(1, "return_token", token)

remote func receive_new_player_logged_in(player_id, info):
	logged_in_players[player_id] = info

remote func return_token_verification_results(result, logged_in_players, scene_to_load):
	match result:
		OK:  # Enter map
			# delete login screen
			print("WE IN BOIZ")
			self.logged_in_players = logged_in_players
			get_tree().change_scene_to(preloaded_scenes[scene_to_load])
			rpc_id(1, "client_ready")
		FAILED:
			# try again
			print("try again")
		ERR_DOES_NOT_EXIST:
			# new account
			get_tree().change_scene_to(preloaded_scenes[scene_to_load])
			self.logged_in_players = logged_in_players


func send_attack(position, direction_vector, animation_state):
	rpc_id(1, "attack", position, direction_vector, animation_state, client_clock)


func send_player_state(player_state):
	# print("Sending player state to server: ", player_state)
	rpc_unreliable_id(1, "receive_player_state", player_state)


# func try_create_new_account(enter_ip_screen, username, color):
# 	if not is_connected(
# 		"account_creation_received", enter_ip_screen, "on_account_creation_received"
# 	):
# 		connect("account_creation_received", enter_ip_screen, "on_account_creation_received")
# 	rpc_id(1, "create_new_account", username, color.to_html(false))

remote func spawn_player(player_id):
	get_tree().current_scene.spawn_player(player_id)
	if player_id == get_tree().get_network_unique_id():
		in_map = true
	# print("spawning player ", player_id, spawn_position)

remote func despawn_player(player_id):
	print("despawning player ", player_id)
	get_tree().current_scene.despawn_player(player_id)

remote func receive_account_creation(error):
	emit_signal("account_creation_received", error)

# Spawn Other player's attack
remote func receive_attack(player_id, position, direction_vector, animation_state, spawn_time):
	if player_id == get_tree().get_network_unique_id():
		pass  # Corect client side predictions
	else:
		get_tree().current_scene.players_dict[player_id].attack_dict[spawn_time] = {}
		var attack_dict = get_tree().current_scene.players_dict[player_id].attack_dict[spawn_time]
		attack_dict.position = position
		attack_dict.direction_vector = direction_vector
		attack_dict.animation_state = animation_state

remote func receive_world_state(world_state):
	# print(world_state)
	if in_map:
		get_tree().current_scene.update_world_state(world_state)

remote func return_skill(s_skill, requester):
	print(s_skill)
	# This is the object that called fetch skill
	print(instance_from_id(requester).name)  #.set_skill(s_skill)

remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() - 1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		latency_delta = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		# print("New Latency: ", latency)
		# print("Latency Delta: ", latency_delta)
		latency_array.clear()

remote func return_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
