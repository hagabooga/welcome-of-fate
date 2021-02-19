class_name Entity
extends Attributes

onready var sprite = $Sprite
onready var collisionbox = $Collisionbox
onready var hurtbox = $Hurtbox
onready var display_name = $EntityUI/DisplayName
onready var hp_bar = $EntityUI/HPBar
onready var hp_bar_tween = $EntityUI/HPBar/Tween

var move_speed = 100

var ming
var id

# func _ready():
# 	self.hp = self.max_hp
# 	connect("on_hp_change", self, "update_hp_bar")
# 	full_hp()
# 	# check state because player might have just logged in and its dead 


func update_hp_bar(max_hp, hp):
	var percentage = int((float(hp) / max_hp) * 100)
	hp_bar_tween.interpolate_property(
		hp_bar, "value", hp_bar.value, percentage, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	hp_bar_tween.start()
	# hp_bar.value = percentage
	if 60 <= percentage:
		hp_bar.tint_progress = Color("14e114")
	elif 25 <= percentage and percentage < 60:
		hp_bar.tint_progress = Color("e1be32")
	else:
		hp_bar.tint_progress = Color("e11e1e")


func take_damage(damage):
	pass
	# Server.entity_hit(get_tree().get_network_unique_id(), damage, "player")
	# # self.hp -= damage
	# # if self.hp <= 0:
	# # 	print("dead")
