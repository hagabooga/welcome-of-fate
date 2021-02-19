class_name Entity
extends Attributes

onready var sprite = $Sprite
onready var collisionbox = $Collisionbox
onready var hurtbox = $Hurtbox
onready var display_name = $EntityUI/DisplayName
onready var hp_bar = $EntityUI/HPBar

var move_speed = 100


func _ready():
	connect("on_hp_change", self, "update_hp_bar")
	full_hp()


func update_hp_bar(max_hp, hp):
	hp_bar.value = int((float(hp) / max_hp) * 100)


func take_damage(damage):
	self.hp -= damage
	if self.hp <= 0:
		print("dead")
