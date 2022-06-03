class_name PlayerTemplate
extends Entity

const sprite_path = "res://UI/CreateCharacterScreen/Sprites/"

var color

var facing := Enums.DIRECTION_DOWN
var can_move := true

var attack_dict = {}

var state_processing: StateProcessing
var combat: Combat
var inventory: Inventory

onready var snake_bite = preload("res://Projectile/SnakeBite/SnakeBite.tscn")
onready var body_animations = $BodyAnimations

var basic_info


func init(
	player_id,
	spawn_position,
	basic_info,
	state_processing: StateProcessing,
	combat: Combat,
	inventory: Inventory
):
	self.basic_info = basic_info
	self.state_processing = state_processing
	self.combat = combat
	self.inventory = inventory
	name = str(player_id)
	ming = basic_info.username
	color = Color.white
	hp = state_processing.logged_in_players[player_id].stats.str * 25
	max_hp = hp


func _ready():
	body_animations.get_child(0).anim_player.connect(
		"animation_finished", self, "on_body_anim_finished"
	)
	# print("template", name)
	set_display_name(ming)
	change_color(color)
	var path = sprite_path + ("Male" if basic_info.gender == Enums.GENDER_MALE else "Female") + "/"
	for body_anim in body_animations.get_children():
		var sprite_name = basic_info[body_anim.name.to_lower()]
		body_anim.texture = load(path + body_anim.name + "/" + sprite_name + ".png")
		var color_key = body_anim.name.to_lower() + "_color"
		if color_key in basic_info:
			body_anim.self_modulate = basic_info[color_key]
	self.max_hp = hp
	connect("on_hp_change", self, "update_hp_bar")


func _physics_process(delta):
	if not attack_dict == {}:
		attack()


# Allow other players to "attack"
func attack():
	for time_stamp in attack_dict:
		if time_stamp <= combat.clock.client_clock:
			# state attack
			var attack = attack_dict[time_stamp]
			var spawn_position = attack.position
			var direction_vector = attack.direction_vector
			var animation_state = attack.animation_state
			facing = attack.animation_state.f
			instance_projectile(snake_bite, spawn_position, direction_vector)
			attack_dict.erase(time_stamp)


func play_all_body_anims(anim, dir = null, speed_ratio = 1, can_move = true):
	self.can_move = can_move
	for x in body_animations.get_children():
		if dir == null:
			x.play_anim(anim, x.current_dir, speed_ratio)
		else:
			x.play_anim(anim, dir, speed_ratio)


func move_player(position, animation_data):
	self.position = position
	if animation_data.a == Enums.ANIMATION_DIE:
		if body_animations.get_child(0).current_anim != Enums.ANIMATION_DIE:
			play_all_body_anims(animation_data.a, animation_data.f)
		return
	play_all_body_anims(animation_data.a, animation_data.f)


func instance_projectile(proj, position, direction_vector):
	proj = proj.instance()
	var angle = self.position.angle_to(position)
	proj.direction = facing
	proj.direction_vector = direction_vector
	proj.global_position = position
	proj.direction = facing
	get_tree().current_scene.add_child(proj)


func on_body_anim_finished(anim_name):
	if anim_name != "die":
		can_move = true
