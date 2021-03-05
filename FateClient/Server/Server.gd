class_name Server
extends Node

signal account_creation_received(error)
signal login_received(error)

var network
var port = 1909

var waiting_for_connection = false
var successfully_connected = false

var logged_in_players = {}

var clock: Clock
var database: Database
var state_processing: StateProcessing
var player_verification: PlayerVerification


func _ready():
	clock = Clock.new()
	database = Database.new()
	state_processing = StateProcessing.new(clock)
	player_verification = PlayerVerification.new(clock, database, state_processing)

	for x in [clock, database, state_processing, player_verification]:
		add_child(x)

	yield(get_tree().create_timer(0.001), "timeout")
	var starting_scene = database.preloaded_scenes[Enums.SCENE_ENTER_IP].instance()
	starting_scene.init(self)
	get_tree().get_root().add_child(starting_scene)
	get_tree().current_scene = starting_scene


func connect_to_server(enter_ip_screen, ip = "127.0.0.1"):
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
	clock.request_server_time_with_client_time()
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", clock, "determine_latency")
	add_child(timer)
	print("Successfully connected.")


func connection_failed():
	print("Failed to connect.")


func fetch_skill(skill_name, requester):
	rpc_id(1, "fetch_skill", skill_name, requester)


func send_attack(position, direction_vector, animation_state):
	print("attacking...")
	# rpc_id(1, "attack", position, direction_vector, animation_state, client_clock)


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

remote func return_skill(s_skill, requester):
	print(s_skill)
	# This is the object that called fetch skill
	print(instance_from_id(requester).name)  #.set_skill(s_skill)
