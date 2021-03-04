extends VBoxContainer

onready var menu_button = $SelectSprite
onready var title = $TitleContainer/Title
onready var segoeuil16 = preload("res://segoeuil16.tres")

var loaded_sprites = []
var sprites_path
var sprite_with_anim

var current_index = 0


func init(title, sprites_path, sprite_with_anim):
	self.title.text = title.capitalize()
	self.sprites_path = sprites_path
	self.sprite_with_anim = sprite_with_anim
	load_sprites()
	menu_button.get_popup().set("custom_fonts/font", segoeuil16)
	menu_button.get_popup().connect("index_pressed", self, "component_selected")
	menu_button.get_popup().emit_signal("index_pressed", current_index)


func component_selected(id):
	current_index = id
	menu_button.text = menu_button.get_popup().get_item_text(id)
	sprite_with_anim.texture = loaded_sprites[id]


func load_sprites():
	var dir = Directory.new()
	if dir.open(sprites_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png.import"):
				var sprite = load(sprites_path + file_name.get_basename())
				loaded_sprites.append(sprite)
				menu_button.get_popup().add_item(
					file_name.get_basename().get_basename().capitalize()
				)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
