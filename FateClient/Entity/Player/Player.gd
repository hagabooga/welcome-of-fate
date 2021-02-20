class_name Player
extends PlayerTemplate

var move_direction = Vector2.ZERO
var speed
var acceleration = 1000
var max_speed = 150

# onready var camera = $Camera2D

onready var turn_axis = $TurnAxis
onready var cast_point = $TurnAxis/CastPoint


# func _ready():
# 	set_physics_process(false)
func _ready():
	# print("player", name)
	self.hp = self.max_hp
	connect("on_hp_change", self, "update_hp_bar")
	full_hp()


func _process(delta):
	if Input.is_action_just_pressed("Attack"):
		var angle = turn_towards_mouse()
		var direction_vector = Vector2(cos(angle), sin(angle))
		turn_axis.rotation = get_angle_to(get_global_mouse_position())
		var proj = snake_bite.instance()
		proj.direction_vector = direction_vector
		proj.position = cast_point.global_position
		proj.direction = facing
		Server.send_attack(proj.position, direction_vector, get_animation_state())
		get_tree().current_scene.add_child(proj)


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

	if move_direction == Vector2.ZERO:
		speed = 0
		play_all_body_anims(SpriteWithBodyAnimation.IDLE, facing)
		return

	if move_direction.x < 0:
		facing = SpriteWithBodyAnimation.LEFT
	elif move_direction.x > 0:
		facing = SpriteWithBodyAnimation.RIGHT
	if move_direction.x == 0 and move_direction.y < 0:
		facing = SpriteWithBodyAnimation.UP
	elif move_direction.x == 0 and move_direction.y > 0:
		facing = SpriteWithBodyAnimation.DOWN
	play_all_body_anims(SpriteWithBodyAnimation.WALK, facing)
	speed += acceleration * delta
	speed = min(speed, max_speed)
	# if velocity.x != 0:
	# 	sprite.flip_h = velocity.x < 0
	move_direction = move_and_slide(move_direction.normalized() * speed)


func send_player_state_to_server():
	# We want to reduce the amount of bytes to send
	var player_state = {}
	player_state.t = Server.client_clock
	player_state.p = global_position
	player_state.a = get_animation_state()
	Server.send_player_state(player_state)


func turn_towards_mouse() -> float:
	var rad_angle = body_animations.global_position.angle_to_point(get_global_mouse_position())
	var angle = rad2deg(rad_angle)
	var cutoff = 55
	var opp = 180 - cutoff
	if -cutoff < angle and angle < cutoff:
		self.facing = SpriteWithBodyAnimation.LEFT
	elif -opp < angle and angle <= -cutoff:
		self.facing = SpriteWithBodyAnimation.DOWN
	elif (-180 <= angle and angle <= -opp) or (opp < angle and angle <= 180):
		self.facing = SpriteWithBodyAnimation.RIGHT
	elif cutoff <= angle and angle <= opp:
		self.facing = SpriteWithBodyAnimation.UP
	return rad_angle + PI


func get_animation_state():
	var animation_state = {}
	animation_state.f = facing
	animation_state.a = body_animations.get_child(0).current_anim
	return animation_state
