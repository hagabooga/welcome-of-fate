extends Node

var data


func _ready():
	var file = File.new()
	file.open("res://accounts.json", File.READ)
	data = parse_json(file.get_as_text())
	print(data)
