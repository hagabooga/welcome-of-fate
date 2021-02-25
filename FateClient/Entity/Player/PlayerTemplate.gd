class_name PlayerTemplate
extends Entity

var color

var facing = Enums.DIRECTION_DOWN
var attack_dict = {}

onready var snake_bite = preload("res://Projectile/SnakeBite/SnakeBite.tscn")
onready var body_animations = $BodyAnimations


func init(player_id, spawn_position, basic):
	name = str(player_id)
	ming = basic.display_name
	color = basic.color


func _ready():
	# print("template", name)
	set_display_name(ming)
	change_color(color)


func _physics_process(delta):
	if not attack_dict == {}:
		attack()


func attack():
	for time_stamp in attack_dict:
		if time_stamp <= Server.client_clock:
			# state attack
			var attack = attack_dict[time_stamp]
			var spawn_position = attack.position
			var direction_vector = attack.direction_vector
			var animation_state = attack.animation_state
			facing = attack.animation_state.f
			instance_projectile(snake_bite, spawn_position, direction_vector)
			attack_dict.erase(time_stamp)


func play_all_body_anims(anim, dir = null, speed_ratio = 1, can_mv = true):
	for x in body_animations.get_children():
		if dir == null:
			x.play_anim(anim, x.current_dir, speed_ratio)
		else:
			x.play_anim(anim, dir, speed_ratio)
	# self.can_move = can_mv


func take_damage(damage):
	Server.entity_hit(get_tree().get_network_unique_id(), damage, "player")


func move_player(position, animation_data):
	self.position = position
	play_all_body_anims(animation_data.a, animation_data.f)


func instance_projectile(proj, position, direction_vector):
	proj = proj.instance()
	var angle = self.position.angle_to(position)
	proj.direction = facing
	proj.direction_vector = direction_vector
	proj.global_position = position
	proj.direction = facing
	get_tree().current_scene.add_child(proj)
