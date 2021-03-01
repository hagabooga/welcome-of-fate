extends HBoxContainer

var text
var create_char_screen

onready var check_box = $CheckBox
onready var color_rect = $ColorRect


func _ready():
	check_box.text = text
	print(get_position_in_parent())
	check_box.connect(
		"pressed", create_char_screen, "on_select_color_part", [get_position_in_parent()]
	)


func init(text, create_char_screen):
	self.text = text
	self.create_char_screen = create_char_screen
