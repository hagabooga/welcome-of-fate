class_name Clock
extends Node


func _init():
	pass


remote func receive_request_server_time_with_client_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(
		player_id, "receive_server_time_with_client_time", OS.get_system_time_msecs(), client_time
	)

remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "receive_latency", client_time)
