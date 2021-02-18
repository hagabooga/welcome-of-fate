extends KinematicBody2D

class_name PlayerTemplate

onready var display_name = $Control/DisplayName

var ming
var color


func init(player_id, spawn_position, basic):
	name = str(player_id)
	ming = basic.display_name
	color = basic.color


func _ready():
	set_display_name(ming)
	change_color(color)


func change_color(color):
	modulate = color


func set_display_name(ming):
	display_name.text = ming


func move_player(position):
	self.position = position
