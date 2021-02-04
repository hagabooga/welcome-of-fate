extends Node

class_name Test


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Server.fetch_skill("fireball", get_instance_id())
