class_name Entity
extends Attributes

onready var sprite = $Sprite
onready var collisionbox = $Collisionbox
onready var hurtbox = $Hurtbox
onready var display_name_panel = $EntityUI/DisplayNamePanel
onready var display_name = $EntityUI/DisplayNamePanel/DisplayName
onready var hp_bar = $EntityUI/HPBar
onready var hp_bar_tween = $EntityUI/HPBar/Tween

# var move_speed = 100

var ming
var id


func change_color(color):
	display_name.add_color_override("font_color", color)


func set_display_name(ming):
	display_name.text = ming
	yield(get_tree().create_timer(.00000001), "timeout")
	display_name_panel.rect_size = display_name_panel.rect_min_size
	display_name_panel.set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
	display_name_panel.margin_left -= 3
	display_name_panel.margin_right += 3
	hp_bar.rect_size = hp_bar.rect_min_size
	hp_bar.set_anchors_and_margins_preset(Control.PRESET_CENTER_TOP)
	hp_bar.margin_left -= int(hp_bar.rect_size.x / 2)


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
