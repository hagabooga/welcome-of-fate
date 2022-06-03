extends Node

var item_database := {}

const path := "res://Singletons/Database/items.json"


func _ready():
	var file = File.new()
	file.open(path, File.READ)
	item_database = parse_json(file.get_as_text())
	print(item_database)
