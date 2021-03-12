extends Control

signal left_clicked


func _ready():
	connect("gui_input", self, "on_gui_input")


func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			emit_signal("left_clicked")
