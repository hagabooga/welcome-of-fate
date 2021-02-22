extends Node

onready var snake_bite = preload("res://SupportScenes/ServerSnakeBite.tscn")
onready var small_worm = preload("res://SupportScenes/ServerSmallWorm.tscn")

onready var enemies = $Objects/Enemies


func spawn_projectile(player_id, position, direction_vector, animation_state, spawn_time):
	var proj = snake_bite.instance()
	proj.player_id = player_id
	proj.global_position = position
	proj.direction_vector = direction_vector
	proj.direction = animation_state.f
	add_child(proj)


func spawn_enemy(enemy_id, location):
	var enemy = small_worm.instance()
	enemy.position = location
	enemy.name = str(enemy_id)
	enemies.add_child(enemy, true)
