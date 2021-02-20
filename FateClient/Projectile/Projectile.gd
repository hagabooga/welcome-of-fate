class_name Projectile
extends Node2D

var direction
var direction_vector
var speed = 150
var duration_multiplier = 0.8

onready var hitbox = $Body/Hitbox
onready var body = $Body
onready var animation_player =$Body/Sprite/AnimationPlayer
onready var sprite = $Body/Sprite

func _ready():
	if direction == SpriteWithBodyAnimation.RIGHT:
		scale.y = -1
		sprite.flip_h = true
	
	animation_player.playback_speed = duration_multiplier
	animation_player.connect("animation_finished", self, "_on_animation_finished")
	var anim
	match direction:
		SpriteWithBodyAnimation.UP:
			anim = "Up"
		SpriteWithBodyAnimation.DOWN:
			anim = "Down"
		SpriteWithBodyAnimation.LEFT, SpriteWithBodyAnimation.RIGHT:
			anim = "Side"
	animation_player.play(anim)
	body.apply_impulse(Vector2.ZERO, direction_vector * speed)


func _on_animation_finished(anim_name):
	queue_free()
