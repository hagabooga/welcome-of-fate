class_name Enemy
extends KinematicBody2D

export (int) var id

var current_target = null
var in_attack_range = false
var speed = 70

var attack_position_start
var attack_position_end
var attack_speed = 1

onready var collision_box = $Collisionbox
onready var range_of_sight = $RangeOfSight
onready var attack_range = $AttackRange
onready var tween = $Tween


func _ready():
	range_of_sight.connect("body_entered", self, "on_range_of_sight_body_entered")
	attack_range.connect("body_entered", self, "on_attack_range_body_entered")
	attack_range.connect("body_exited", self, "on_attack_range_body_exited")


# 	tween.connect("tween_started", self, "on_tween_started")
# 	tween.connect("tween_completed", self, "on_tween_completed")

# func on_tween_started(obj, key):
# 	collision_box.disabled = true

# func on_tween_completed(obj, key):
# 	collision_box.disabled = false


func _physics_process(delta):
	if current_target == null:
		return
	if in_attack_range:
		if tween.is_active():
			return
		attack_position_start = global_position
		attack_position_end = current_target.global_position
		attack_position_end -= (
			attack_position_start.direction_to(attack_position_end)
			* attack_position_start.distance_to(attack_position_end)
			* 0.4
		)
		tween.interpolate_property(
			self, "global_position", attack_position_start, attack_position_end, attack_speed * 0.1
		)
		tween.interpolate_property(
			self,
			"global_position",
			attack_position_end,
			attack_position_start,
			attack_speed * 0.9,
			0,
			Tween.EASE_IN_OUT,
			attack_speed * 0.1
		)
		tween.start()
		return
	var move_direction = global_position.direction_to(current_target.global_position)
	move_and_slide(speed * move_direction)


func on_range_of_sight_body_entered(body):
	if body.is_in_group("Player") and current_target == null:
		current_target = body


func on_attack_range_body_entered(body):
	if body == current_target:
		in_attack_range = true


func on_attack_range_body_exited(body):
	if body == current_target:
		in_attack_range = false

# var ming
# var hp
# var armor
# var resist
# var damage
# var time_out = 1
# var spawn_id
# var loc
# var state = Enums.ENTITY_ALIVE

# func init(spawn_id, loc):
# 	var stats = Database.enemies.get_enemy(enemy_id)
# 	self.ming = stats.ming
# 	self.hp = stats.hp
# 	self.armor = stats.armor
# 	self.resist = stats.resist
# 	self.damage = stats.damage
# 	self.spawn_id = spawn_id
# 	self.loc = loc

# func to_dict():
# 	var dict = {}
# 	dict.ming = ming
# 	dict.hp = hp
# 	dict.armor = armor
# 	dict.resist = resist
# 	dict.damage = damage
# 	dict.id = spawn_id
# 	dict.loc = loc
# 	dict.state = state
# 	return dict
