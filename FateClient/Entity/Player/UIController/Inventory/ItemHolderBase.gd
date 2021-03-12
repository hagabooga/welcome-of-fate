class_name ItemHolderBase
extends TextureButton

signal left_clicked
signal hovering(item)
signal dropped_data

var item: Item = null setget set_item
var count := 0 setget set_count

onready var item_texture = $ItemTexture
onready var item_count = $ItemCount


func _ready() -> void:
	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")
	connect("gui_input", self, "on_gui_input")
	# connect("left_clicked", self, "on_holding")


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			on_released()


func on_mouse_entered() -> void:
	emit_signal("hovering", item)


func on_mouse_exited() -> void:
	pass


func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				emit_signal("left_clicked")


func on_released() -> void:
	item_texture.modulate.a = 1


func on_holding() -> void:
	item_texture.modulate.a = 0.4


func is_stackable() -> bool:
	return true


func get_texture() -> Texture:
	return item_texture.texture


func clear() -> void:
	item = null
	self.count = 0
	item_count.text = ""
	on_released()
	item_texture.texture = null


func set_count(value: int) -> void:
	count = value
	item_count.text = str(value)


func set_item(i: Item, amount := 1) -> void:
	if i == null:
		return
	item = i
	item_texture.texture = load("res://Item/Sprites/" + item.ming + ".png")
	self.count = amount
	item_count.visible = is_stackable()


func disable(yes: bool) -> void:
	disabled = yes


func get_drag_data(position):
	var t = TextureRect.new()
	t.texture = item_texture.texture
	set_drag_preview(t)
	on_holding()
	return self


func can_drop_data(position, data):
	return true


func drop_data(position, data):
	data.on_released()
	if item == null:
		set_item(data.item, data.count)
		data.clear()
	else:
		var temp = [item, count]
		set_item(data.item, data.count)
		data.callv("set_item", temp)

	emit_signal("dropped_data")
