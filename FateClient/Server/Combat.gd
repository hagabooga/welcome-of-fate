class_name Combat
extends Node

var clock: Clock


func _init(clock: Clock):
	name = "Combat"
	self.clock = clock


func send_attack(position, direction_vector, animation_state):
	rpc_id(1, "attack", position, direction_vector, animation_state, clock.client_clock)


# Spawn Other player's attack
remote func receive_attack(player_id, position, direction_vector, animation_state, spawn_time):
	if player_id == get_tree().get_network_unique_id():
		pass  # Corect client side predictions
	else:
		print("GG")
		get_tree().current_scene.players_dict[player_id].attack_dict[spawn_time] = {}
		var attack_dict = get_tree().current_scene.players_dict[player_id].attack_dict[spawn_time]
		attack_dict.position = position
		attack_dict.direction_vector = direction_vector
		attack_dict.animation_state = animation_state
