class_name SceneManager
extends Node

var server
var clock: Clock
var database: Database
var state_processing: StateProcessing
var account_creation: AccountCreation

var preloaded_scenes: Dictionary


func _init(
	server,
	clock: Clock,
	database: Database,
	state_processing: StateProcessing,
	account_creation: AccountCreation
):
	name = "SceneManager"
	self.server = server
	self.clock = clock
	self.database = database
	self.state_processing = state_processing
	self.account_creation = account_creation

	preloaded_scenes = {
		Enums.SCENE_ENTER_IP: [preload("res://UI/EnterIPScreen/EnterIPScreen.tscn"), [server]],
		Enums.SCENE_TEST_MAP: [preload("res://Map/TestMap.tscn"), [clock, state_processing]],
		Enums.SCENE_CREATE_CHARACTER:
		[preload("res://UI/CreateCharacterScreen/CreateCharacterScreen.tscn"), [account_creation]]
	}


func instance_scene_and_init(scene_id) -> Node:
	var scene = preloaded_scenes[scene_id][0]
	var args = preloaded_scenes[scene_id][1]
	var instance = scene.instance()
	instance.callv("init", args)
	return instance


func add_and_set_scene_to(scene_id):
	var instance = instance_scene_and_init(scene_id)
	get_tree().get_root().add_child(instance)
	get_tree().current_scene = instance


func change_scene_to(scene_id: int):
	var instance = instance_scene_and_init(scene_id)
	get_tree().get_root().add_child(instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = instance
