class_name StateProcessing
extends Node

var clock: Clock
var logged_in_players := {}
var in_map = false


func _init(clock: Clock):
	self.clock = clock
	name = "StateProcessing"


func send_player_state(player_state: Dictionary) -> void:
	# print("Sending player state to server: ", player_state)
	player_state.t = clock.client_clock
	rpc_unreliable_id(1, "receive_player_state", player_state)


remote func player_disconnected(player_id: int):
	print("player_disconnected: ", player_id) 
	logged_in_players.erase(player_id)

remote func despawn_player(player_id):
	if in_map:
		print("despawning player ", player_id)
		get_tree().current_scene.despawn_player(player_id)

remote func receive_world_state(world_state):
	# print(world_state)
	if in_map:
		get_tree().current_scene.update_world_state(world_state)
