class_name PlayerTemplate
extends Entity

onready var body_animations = $BodyAnimations
var color


func _ready():
	print("template", name)
	set_display_name(ming)
	change_color(color)


func play_all_body_anims(anim, dir = null, speed_ratio = 1, can_mv = true):
	for x in body_animations.get_children():
		if dir == null:
			x.play_anim(anim, x.current_dir, speed_ratio)
		else:
			x.play_anim(anim, dir, speed_ratio)
	# self.can_move = can_mv


func take_damage(damage):
	Server.entity_hit(get_tree().get_network_unique_id(), damage, "player")


func init(player_id, spawn_position, basic):
	name = str(player_id)
	ming = basic.display_name
	color = basic.color


func move_player(position):
	self.position = position
