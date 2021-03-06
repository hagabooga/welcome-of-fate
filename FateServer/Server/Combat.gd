class_name Combat
extends Node

var database: Database
var map


func _init(map, database: Database):
	self.map = map
	self.database = database
	name = "Combat"


remote func attack(position, direction_vector, animation_state, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	map.spawn_projectile(player_id, position, direction_vector, animation_state, spawn_time)
	rpc_id(0, "receive_attack", player_id, position, direction_vector, animation_state, spawn_time)
