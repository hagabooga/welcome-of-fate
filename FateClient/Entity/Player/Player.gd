class_name Player
extends PlayerTemplate

var move_direction = Vector2.ZERO
var speed = 0
var acceleration = 1000
var max_speed = 150

# onready var camera = $Camera2D
onready var turn_axis = $TurnAxis
onready var cast_point = $TurnAxis/CastPoint
onready var ui_controller = $UIController


func _ready():
	self.max_hp = 100
	ui_controller.mouse_input.connect("left_clicked", self, "on_left_click")
	# connect("on_hp_change", self, "update_hp_bar")
	# full_hp()


func _process(delta):
	if not can_move:
		return
	turn_towards_mouse()


func _physics_process(delta):
	movement_loop(delta)
	send_player_state_to_server()


func on_left_click():
	if not can_move:
		return
	play_all_body_anims(Enums.ANIMATION_CAST, facing, 1, false)
	var angle = turn_towards_mouse()
	var direction_vector = Vector2(cos(angle), sin(angle))
	turn_axis.rotation = get_angle_to(get_global_mouse_position())
	instance_projectile(snake_bite, cast_point.global_position, direction_vector)
	combat.send_attack(cast_point.global_position, direction_vector, get_animation_state())


func movement_loop(delta):
	if not can_move:
		return
	move_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1

	if move_direction == Vector2.ZERO:
		speed = 0
		play_all_body_anims(Enums.ANIMATION_IDLE, facing)
		return

	if move_direction.x < 0:
		facing = Enums.DIRECTION_LEFT
	elif move_direction.x > 0:
		facing = Enums.DIRECTION_RIGHT
	if move_direction.x == 0 and move_direction.y < 0:
		facing = Enums.DIRECTION_UP
	elif move_direction.x == 0 and move_direction.y > 0:
		facing = Enums.DIRECTION_DOWN
	play_all_body_anims(Enums.ANIMATION_WALK, facing)
	speed += acceleration * delta
	speed = min(speed, max_speed)
	move_direction = move_and_slide(move_direction.normalized() * speed)


func send_player_state_to_server():
	# We want to reduce the amount of bytes to send
	var player_state = {}
	player_state.p = global_position
	player_state.a = get_animation_state()
	state_processing.send_player_state(player_state)
	# Server.send_player_state(player_state)


func get_animation_state():
	var animation_state = {}
	animation_state.f = facing
	animation_state.a = body_animations.get_child(0).current_anim
	return animation_state


func turn_towards_mouse() -> float:
	var rad_angle = body_animations.global_position.angle_to_point(get_global_mouse_position())
	self.facing = Utility.get_direction(rad_angle)
	return rad_angle + PI


func die():
	play_all_body_anims(Enums.ANIMATION_DIE, null, 1, false)
