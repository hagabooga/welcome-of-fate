extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 300

onready var sprite = $Sprite

# func _ready():
# 	set_physics_process(false)


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

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	velocity = move_and_slide(velocity.normalized() * speed)


func send_player_state_to_server():
	# We want to reduce the amount of bytes to send
	var player_state = {"t": OS.get_system_time_msecs(), "p": global_position}
	Server.send_player_state(player_state)
