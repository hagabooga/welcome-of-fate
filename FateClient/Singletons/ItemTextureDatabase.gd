extends Node

const path := "res://Item/Sprites/"

var database := {}


func _ready():
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png.import"):
				print(file_name.get_basename())
				var texture = load(path + file_name.get_basename())
				database[file_name.get_basename().get_basename()] = texture
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func get_item_texture(ming: String) -> Texture:
	return database.get(ming)
