class_name Player
extends PlayerTemplate

var move_direction = Vector2.ZERO
var speed
var acceleration = 1000
var max_speed = 150
# onready var camera = $Camera2D


# func _ready():
# 	set_physics_process(false)
func _ready():
	print("player", name)
	self.hp = self.max_hp
	connect("on_hp_change", self, "update_hp_bar")
	full_hp()


# func _process(delta):
# 	if Input.is_action_just_pressed("ui_accept"):
# 		take_damage(10)


func _physics_process(delta):
	movement_loop(delta)
	send_player_state_to_server()


func movement_loop(delta):
	move_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1

	if move_direction.x < 0:
		play_all_body_anims(SpriteWithBodyAnimation.WALK, SpriteWithBodyAnimation.LEFT)
	elif move_direction.x > 0:
		play_all_body_anims(SpriteWithBodyAnimation.WALK, SpriteWithBodyAnimation.RIGHT)
	if move_direction.x == 0 and move_direction.y < 0:
		play_all_body_anims(SpriteWithBodyAnimation.WALK, SpriteWithBodyAnimation.UP)
	elif move_direction.x == 0 and move_direction.y > 0:
		play_all_body_anims(SpriteWithBodyAnimation.WALK, SpriteWithBodyAnimation.DOWN)

	if move_direction == Vector2.ZERO:
		speed = 0
		play_all_body_anims(SpriteWithBodyAnimation.IDLE)
	else:
		speed += acceleration * delta
		speed = min(speed, max_speed)
	# if velocity.x != 0:
	# 	sprite.flip_h = velocity.x < 0
	move_direction = move_and_slide(move_direction.normalized() * speed)


func send_player_state_to_server():
	# We want to reduce the amount of bytes to send
	var player_state = {"t": OS.get_system_time_msecs(), "p": global_position}
	Server.send_player_state(player_state)
