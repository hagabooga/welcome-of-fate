class_name Clock
extends Node

var client_clock := 0
var decimal_collector: float = 0
var latency := 0
var latency_delta := 0
var latencies := []


func _init():
	pass


func _physics_process(delta):  #0.01667
	client_clock += int(delta * 1000) + latency_delta
	latency_delta = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00


func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())


func request_server_time_with_client_time():
	rpc_id(1, "receive_request_server_time_with_client_time", OS.get_system_time_msecs())


remote func receive_latency(client_time):
	latencies.append((OS.get_system_time_msecs() - client_time) / 2)
	if latencies.size() == 9:
		var total_latency = 0
		latencies.sort()
		var mid_point = latencies[4]
		for i in range(latencies.size() - 1, -1, -1):
			if latencies[i] > (2 * mid_point) and latencies[i] > 20:
				latencies.remove(i)
			else:
				total_latency += latencies[i]
		latency_delta = (total_latency / latencies.size()) - latency
		latency = total_latency / latencies.size()
		# print("New Latency: ", latency)
		# print("Latency Delta: ", latency_delta)
		latencies.clear()

remote func receive_server_time_with_client_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
