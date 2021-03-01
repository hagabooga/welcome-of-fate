extends Control

var selections = ["Body", "Eyes", "Hair"]
var color_selections = ["Eyes", "Hair"]

var current_color_part = null

onready var color_options = $PickColors/ColorOptions
onready var color_picker = $PickColors/ColorPicker
onready var segoeuil16 = preload("res://segoeuil16.tres")
onready var check_box_with_color = preload("res://UI/CreateCharacterScreen/CheckboxWithColor.tscn")

var sprites_with_anim_preview
var sprites_path


func _ready():
	for i in range(len(color_selections)):
		var check_box_with_color_instance = check_box_with_color.instance()
		check_box_with_color_instance.init(color_selections[i], self)
		check_box_with_color_instance.name = color_selections[i]
		color_options.add_child(check_box_with_color_instance)

	for selection in selections:
		get_node(selection).init(
			selection, sprites_path + selection + "/", sprites_with_anim_preview.get_node(selection)
		)

	color_picker.connect("color_changed", self, "on_color_changed")


func init(sprites_with_anim_preview, sprites_path):
	self.sprites_with_anim_preview = sprites_with_anim_preview
	self.sprites_path = sprites_path


func select_current_selected():
	for selection in selections:
		var popup = get_node(selection).menu_button.get_popup()
		popup.emit_signal("index_pressed", get_node(selection).current_index)
	for color in color_selections:
		color = color.capitalize()

		sprites_with_anim_preview.get_node(color).self_modulate = color_options.get_node(
			color
		).color_rect.color


func on_color_changed(color):
	if current_color_part != null:
		sprites_with_anim_preview.get_node(current_color_part.text).self_modulate = color
		current_color_part.color_rect.color = color


func on_select_color_part(id):
	if color_options.get_child(id).check_box.pressed == false:
		current_color_part = null
		return
	current_color_part = color_options.get_child(id)
	for i in color_options.get_children().slice(1, color_options.get_child_count()):
		if i.get_position_in_parent() != id:
			i.check_box.pressed = false


func get_character_data():
	var data = {}
	for x in selections:
		data[x.to_lower()] = get_node(x).menu_button.text.replace(" ", "").to_lower()
	for x in color_options.get_children().slice(1, color_options.get_child_count()):
		data[x.check_box.text.to_lower() + "_color"] = x.color_rect.color.to_html(false)
	return data
