extends Node

var port = 1909
var max_players = 100

# token : basic_player_info
# var expected_tokens = {}

#onready var map = $Map

onready var map = $Map

var network: NetworkedMultiplayerENet
var clock: Clock
var database: Database
var combat: Combat
var player_verification: PlayerVerification
var hub_connection: HubConnection
var state_processing: StateProcessing
var account_creation: AccountCreation


# rpc_id(0, ...) calls function to all clients
func _ready():
	network = NetworkedMultiplayerENet.new()
	clock = Clock.new()
	database = Database.new()
	combat = Combat.new(map, database)
	state_processing = StateProcessing.new(map, database)
	map.init(database, state_processing, network)
	player_verification = PlayerVerification.new(database, state_processing, network)
	hub_connection = HubConnection.new(player_verification)
	account_creation = AccountCreation.new(database, state_processing, player_verification)

	for x in [
		clock,
		database,
		combat,
		player_verification,
		hub_connection,
		state_processing,
		account_creation
	]:
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

	state_processing.logged_in_players.erase(player_id)
	state_processing.connected_players.erase(player_id)

	state_processing.player_disconnected(player_id)

	if player_id in state_processing.player_states:
		state_processing.player_states.erase(player_id)
		state_processing.despawn_player(player_id)


remote func fetch_skill(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var skill = ServerData.get_skill(skill_name)
	rpc_id(player_id, "return_skill", skill, requester)
	print("Sending " + str(skill) + " to player.")
