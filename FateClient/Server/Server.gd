class_name Server
extends Node

# signal login_received(error)

var network
var port = 1909

var waiting_for_connection = false
var successfully_connected = false

var logged_in_players = {}

var clock: Clock
var database: Database
var state_processing: StateProcessing
var account_creation: AccountCreation
var scene_manager: SceneManager
var player_verification: PlayerVerification


func _ready():
	clock = Clock.new()
	database = Database.new()
	state_processing = StateProcessing.new(clock)
	account_creation = AccountCreation.new()
	scene_manager = SceneManager.new(self, clock, database, state_processing, account_creation)
	player_verification = PlayerVerification.new(clock, database, state_processing, scene_manager)

	for x in [
		clock, database, scene_manager, account_creation, state_processing, player_verification
	]:
		add_child(x)

	yield(get_tree(), "idle_frame")
	scene_manager.add_and_set_scene_to(Enums.SCENE_ENTER_IP)


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


remote func return_skill(s_skill, requester):
	print(s_skill)
	# This is the object that called fetch skill
	print(instance_from_id(requester).name)  #.set_skill(s_skill)
