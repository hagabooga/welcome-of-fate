class_name Projectile
extends Node2D

var direction
var direction_vector
var speed = 150
var duration_multiplier = 0.8
var velocity

onready var hitbox = $Body/Hitbox
onready var body = $Body
onready var animation_player = $Body/AnimationPlayer
onready var sprite = $Body/Sprite


func _ready():
	animation_player.playback_speed = duration_multiplier
	animation_player.connect("animation_finished", self, "_on_animation_finished")
	var anim
	match direction:
		Enums.DIRECTION_UP:
			anim = "Up"
		Enums.DIRECTION_DOWN:
			anim = "Down"
		Enums.DIRECTION_LEFT:
			anim = "Side"
		Enums.DIRECTION_RIGHT:
			anim = "Side"

	animation_player.play(anim)
	if direction == Enums.DIRECTION_RIGHT:
		scale.x = -scale.x
	velocity = Vector2.ONE * direction_vector * speed
	# else:
	# 	hitbox.connect("area_entered", self, "hit_entity")


func _physics_process(delta):
	body.move_and_slide(velocity)


func _on_animation_finished(anim_name):
	queue_free()

# func hit_entity(body):
# 	if body.get_parent() is Enemy:
# 		body.get_parent().take_damage(23)
