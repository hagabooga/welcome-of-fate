extends Node

onready var test_map = preload("res://Map/TestMap.tscn")

var network
var port = 1909

var waiting_for_connection = false
var successfully_connected = false


func connect_to_server(display_name, color, ip = "127.0.0.1"):
	AllPlayersInfo.user_basic = BasicPlayerInfo.new(display_name, color)
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().network_peer = network
	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")
	waiting_for_connection = true
	yield(get_tree().create_timer(5.0), "timeout")
	if not successfully_connected:
		print("Connection Timed Out")
		waiting_for_connection = false


func connection_succeeded():
	waiting_for_connection = false
	successfully_connected = true
	get_tree().change_scene_to(test_map)
	print("Successfully connected.")


func connection_failed():
	print("Failed to connect.")


# Fetch from server
# Calls function on server
# server calls return method


func fetch_skill(skill_name, requester):
	rpc_id(1, "fetch_skill", skill_name, requester)


func send_player_state(player_state):
	# print("Sending player state to server: ", player_state)
	rpc_unreliable_id(1, "recieve_player_state", player_state)


remote func spawn_player(player_id, spawn_position, basic_player_info):
	AllPlayersInfo.basics[player_id] = BasicPlayerInfo.new(basic_player_info.n, basic_player_info.c)
	get_tree().current_scene.spawn_player(player_id, spawn_position)
	# print("spawning player ", player_id, spawn_position)

remote func despawn_player(player_id):
	print("despawning player ", player_id)
	get_tree().current_scene.despawn_player(player_id)

remote func return_skill(s_skill, requester):
	print(s_skill)
	# This is the object that called fetch skill
	print(instance_from_id(requester).name)  #.set_skill(s_skill)

remote func recieve_world_state(world_state):
	# print(world_state)
	get_tree().current_scene.update_world_state(world_state)

remote func send_basic_player_info(player_id):
	rpc_id(
		1,
		"recieve_basic_player_info",
		{"n": AllPlayersInfo.user_basic.display_name, "c": AllPlayersInfo.user_basic.color}
	)
