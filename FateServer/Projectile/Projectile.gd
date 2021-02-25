class_name Projectile
extends Node2D

var direction
var direction_vector
var speed = 150
var duration_multiplier = 0.8
var velocity
var real
var player_id
var damage

onready var hitbox = $Body/Hitbox
onready var body = $Body
onready var animation_player = $Body/AnimationPlayer


func _ready():
	damage = 23
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
	hitbox.connect("area_entered", self, "hit_entity")


func _physics_process(delta):
	body.move_and_slide(velocity)


func _on_animation_finished(anim_name):
	queue_free()


func hit_entity(body):
	var entity = body.get_parent()
	if entity.is_in_group("Enemies"):
		get_parent().enemy_hit(entity.get_meta("id"), damage)
