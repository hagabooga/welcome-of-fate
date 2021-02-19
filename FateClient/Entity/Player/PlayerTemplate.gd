class_name PlayerTemplate
extends Entity

var color


func take_damage(damage):
	Server.entity_hit(get_tree().get_network_unique_id(), damage, "player")


func init(player_id, spawn_position, basic):
	name = str(player_id)
	ming = basic.display_name
	color = basic.color


func _ready():
	set_display_name(ming)
	change_color(color)


func change_color(color):
	display_name.modulate = color


func set_display_name(ming):
	display_name.text = ming


func move_player(position):
	self.position = position
