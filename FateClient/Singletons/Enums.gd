extends Node

enum { DIRECTION_UP, DIRECTION_DOWN, DIRECTION_LEFT, DIRECTION_RIGHT }

var _direction_to_string: Dictionary = {
	DIRECTION_UP: "Up", DIRECTION_DOWN: "Down", DIRECTION_LEFT: "Left", DIRECTION_RIGHT: "Right"
}


func direction_to_string(direction: int) -> String:
	return _direction_to_string[direction]


enum {
	ANIMATION_IDLE,
	ANIMATION_WALK,
	ANIMATION_HACK,
	ANIMATION_SLASH,
	ANIMATION_CAST,
	ANIMATION_DIE
}

enum { ENTITY_ALIVE, ENTITY_DEAD }

enum { SCENE_TEST_MAP, SCENE_CREATE_CHARACTER, SCENE_ENTER_IP }

enum { GENDER_MALE, GENDER_FEMALE }
