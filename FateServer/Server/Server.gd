extends Node

var port = 1909
var max_players = 100

var logged_in_players = {}

# token : basic_player_info
# var expected_tokens = {}

#onready var map = $Map

onready var map = $Map

var network: NetworkedMultiplayerENet
var clock: Clock
var database: Database
var player_verification: PlayerVerification
var hub_connection: HubConnection
var state_processing: StateProcessing


# rpc_id(0, ...) calls function to all clients
func _ready():
	network = NetworkedMultiplayerENet.new()
	clock = Clock.new()
	database = Database.new()
	state_processing = StateProcessing.new(map, database)
	map.init(database, state_processing, network)
	player_verification = PlayerVerification.new(database, state_processing, network)
	hub_connection = HubConnection.new(player_verification)

	for x in [clock, database, player_verification, hub_connection, state_processing]:
		add_child(x)

	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	network.connect("peer_connected", self, "peer_connected")
	network.connect("peer_disconnected", self, "peer_disconnected")


func peer_connected(player_id):
	print("User " + str(player_id) + " connected.")
	player_verification.start(player_id)


func peer_disconnected(player_id):
	var str_player_id = str(player_id)
	print("User " + str_player_id + " disconnected.")
	if player_id in logged_in_players:
		logged_in_players.erase(player_id)

	if state_processing.player_states.has(player_id):
		state_processing.player_states.erase(player_id)
		rpc_id(0, "despawn_player", player_id)

	if player_id in state_processing.connected_players:
		state_processing.connected_players.erase(player_id)


remote func attack(position, direction_vector, animation_state, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	map.spawn_projectile(player_id, position, direction_vector, animation_state, spawn_time)
	rpc_id(0, "receive_attack", player_id, position, direction_vector, animation_state, spawn_time)

remote func fetch_skill(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var skill = ServerData.get_skill(skill_name)
	rpc_id(player_id, "return_skill", skill, requester)
	print("Sending " + str(skill) + " to player.")
