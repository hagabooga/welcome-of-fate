class_name SpriteWithBodyAnimation
extends Sprite

var current_anim
var current_dir = DOWN
# var current_anim = "idle"
enum { UP, DOWN, LEFT, RIGHT }
enum { IDLE, WALK, HACK, SLASH, CAST, DIE }
var direction_to_string = {UP: "up", DOWN: "down", LEFT: "left", RIGHT: "right"}
var animation_to_string = {
	IDLE: "idle", WALK: "walk", HACK: "hack", SLASH: "slash", CAST: "cast", DIE: "die"
}

# 5 / 5 = 1.6


func play_anim(anim, dir = current_dir, speed_ratio = 5):
	current_anim = anim
	current_dir = dir
	# current_dir = dir
	# current_anim = anim
	var anim_string = animation_to_string[anim]
	$AnimationPlayer.play(
		(
			anim_string
			if anim_string == "die"
			else "%s_%s" % [anim_string, direction_to_string[current_dir]]
		)
	)
	$AnimationPlayer.playback_speed = speed_ratio * $AnimationPlayer.current_animation_length
