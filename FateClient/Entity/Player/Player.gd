class_name Player
extends PlayerTemplate

var velocity = Vector2.ZERO

# onready var camera = $Camera2D

# func _ready():
# 	set_physics_process(false)


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		take_damage(10)


func _physics_process(delta):
	movement_loop(delta)
	send_player_state_to_server()


func movement_loop(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1

	# if velocity.x != 0:
	# 	sprite.flip_h = velocity.x < 0

	velocity = move_and_slide(velocity.normalized() * move_speed)


func send_player_state_to_server():
	# We want to reduce the amount of bytes to send
	var player_state = {"t": OS.get_system_time_msecs(), "p": global_position}
	Server.send_player_state(player_state)
