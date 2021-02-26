extends Node

onready var server = get_tree().current_scene
var awaiting_verification = {}

var verification_expiration = Timer.new()


func _ready():
	add_child(verification_expiration)
	verification_expiration.wait_time = 10
	verification_expiration.one_shot = false
	verification_expiration.start()
	verification_expiration.connect("timeout", self, "on_verification_expireation_timeout")


func start(player_id):
	awaiting_verification[player_id] = {"time_stamp": OS.get_unix_time()}
	server.fetch_token(player_id)


func verify(player_id, token):
	var good = false
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if token in server.expected_tokens:
			good = true
			print(player_id, " success verification")
			# create player container
			awaiting_verification.erase(player_id)
			server.expected_tokens.erase(token)
			break
		yield(get_tree().create_timer(2), "timeout")
	server.return_token_verification_results(player_id, good)
	if not good:  # Make sure people are disconnected
		awaiting_verification.erase(player_id)
		server.network.disconnect_peer(player_id)


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
					server.return_token_verification_results(key, false)
					server.network.disconnect_peer(key)
	print("awaiting verifications: ", awaiting_verification)
