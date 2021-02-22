class_name SpriteWithBodyAnimation
extends Sprite

var current_anim
var current_dir = Enums.DIRECTION_DOWN
# var current_anim = "idle"

var direction_to_string = {
	Enums.DIRECTION_UP: "up",
	Enums.DIRECTION_DOWN: "down",
	Enums.DIRECTION_LEFT: "left",
	Enums.DIRECTION_RIGHT: "right"
}
var animation_to_string = {
	Enums.ANIMATION_IDLE: "idle",
	Enums.ANIMATION_WALK: "walk",
	Enums.ANIMATION_HACK: "hack",
	Enums.ANIMATION_SLASH: "slash",
	Enums.ANIMATION_CAST: "cast",
	Enums.ANIMATION_DIE: "die"
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
