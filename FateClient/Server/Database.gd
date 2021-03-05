class_name Database
extends Node

var token: String

onready var preloaded_scenes = {
	Enums.SCENE_ENTER_IP: preload("res://UI/EnterIPScreen/EnterIPScreen.tscn"),
	Enums.SCENE_TEST_MAP: preload("res://Map/TestMap.tscn"),
	Enums.SCENE_CREATE_CHARACTER:
	preload("res://UI/CreateCharacterScreen/CreateCharacterScreen.tscn")
}


func _init():
	name = "Database"
	pass
