extends CanvasLayer

const sprites_path = "res://UI/CreateCharacterScreen/Sprites/"

var selections = ["body", "eyes", "hair"]

var options = []
var facing = Enums.DIRECTION_DOWN

onready var sprites_with_anim_preview = $Screen/VBoxContainer/SpritesWithAnimPreview
onready var create_char_options = preload("CreateCharacterOptions.tscn")
onready var buttons = $Screen/VBoxContainer/Buttons

onready var gender_check = $Screen/VBoxContainer/Buttons/SelectGender/GenderCheck
onready var confirm_button = $Screen/VBoxContainer/SpritesWithAnimPreview/Confirm

var server

func _ready():
	for path in ["Male", "Female"]:
		var options_instance = create_char_options.instance()
		options_instance.init(sprites_with_anim_preview, sprites_path + path + "/")
		buttons.add_child(options_instance)
		options.append(options_instance)

	options[1].hide()

	play_body_anims(Enums.ANIMATION_WALK, Enums.DIRECTION_DOWN, 1)

	gender_check.connect("toggled", self, "gender_toggle")
	gender_toggle(false)
	confirm_button.connect("pressed", self, "on_confirm_pressed")


func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		facing = Enums.DIRECTION_UP
	if Input.is_action_just_pressed("ui_down"):
		facing = Enums.DIRECTION_DOWN
	if Input.is_action_just_pressed("ui_left"):
		facing = Enums.DIRECTION_LEFT
	if Input.is_action_just_pressed("ui_right"):
		facing = Enums.DIRECTION_RIGHT

	play_body_anims(Enums.ANIMATION_WALK, facing, 1)


func on_confirm_pressed():
	var data = options[1] if gender_check.pressed else options[0]
	data = data.get_character_data()
	data.gender = Enums.GENDER_FEMALE if gender_check.pressed else Enums.GENDER_MALE
	server.send_new_character_data(data)


func gender_toggle(female):
	if female:
		options[1].show()
		options[1].select_current_selected()
		options[0].hide()
	else:
		options[0].show()
		options[0].select_current_selected()
		options[1].hide()


func play_body_anims(anim, dir, speed):
	for body in sprites_with_anim_preview.get_children().slice(
		0, sprites_with_anim_preview.get_child_count() - 3
	):
		body.play_anim(anim, dir, speed)
