extends Node2D

var player_actual = preload("res://Player/Player.tscn")
var player_template = preload("res://Player/PlayerTemplate.tscn")

onready var players = $Objects/Players
var players_dict = {}


func _ready():
	players.add_child(player_actual.instance())


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		print(players_dict)


func spawn_player(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		# The client itself 
		print("GG")
		pass
	else:
		# Spawn other player
		print("spawning ", player_id)
		var new_player = player_template.instance()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		players.add_child(new_player)
		players_dict[player_id] = new_player


func despawn_player(player_id):
	print("despawning ", player_id)
	players_dict[player_id].queue_free()
	players_dict.erase(player_id)
