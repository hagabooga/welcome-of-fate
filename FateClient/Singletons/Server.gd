extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909


func _ready():
	connect_to_server()


func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")


func connection_succeeded():
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


remote func spawn_new_player(player_id, spawn_position):
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
