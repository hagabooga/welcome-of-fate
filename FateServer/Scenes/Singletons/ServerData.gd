extends Node

var skill_data


func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://skills.json", File.READ)
	skill_data = JSON.parse(skill_data_file.get_as_text()).result
	print(skill_data)


func get_skill(skill_name):
	return skill_data[skill_name]
