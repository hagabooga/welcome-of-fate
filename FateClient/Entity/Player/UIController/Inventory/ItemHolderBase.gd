class_name ItemHolderBase
extends TextureButton

signal left_clicked(holder)
signal right_clicked(holder)
signal double_clicked(holder)

signal hovering(item)
signal dropped_data

var item: Item = null setget set_item
var count := 0 setget set_count
var item_drag_preview = null

onready var item_texture: TextureRect = $ItemTexture
onready var item_count: Label = $ItemCount


func _ready() -> void:
	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")
	connect("gui_input", self, "on_gui_input")
	# connect("left_clicked", self, "on_holding")


func init(item_drag_preview):
	self.item_drag_preview = item_drag_preview


func on_mouse_entered() -> void:
	emit_signal("hovering", item)


func on_mouse_exited() -> void:
	# print("Exited: ", name)
	pass


func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_LEFT:
					if event.doubleclick:
						emit_signal("double_clicked", self)
					else:
						emit_signal("left_clicked", self)
				BUTTON_RIGHT:
					emit_signal("right_clicked", self)


# func on_released() -> void:
# 	item_texture.modulate.a = 1

# func on_holding() -> void:
# 	item_texture.modulate.a = 0.4


func is_stackable() -> bool:
	return true


func get_texture() -> Texture:
	return item_texture.texture


func clear() -> void:
	item = null
	count = 0
	item_count.text = ""
	item_texture.texture = null


func set_count(value: int) -> void:
	count = value
	item_count.text = str(value)
	if count <= 0:
		clear()


func set_item(i: Item, amount := 1) -> void:
	if i == null:
		return
	item = i
	item_texture.texture = ItemTextureDatabase.get_item_texture(item.ming)
	self.count = amount
	item_count.visible = is_stackable()


func disable(yes: bool) -> void:
	disabled = yes

# func get_drag_data(position):
# 	if item != null:
# 		item_drag_preview.texture = item_texture.texture 
# 		set_drag_preview(item_drag_preview)
# 		on_holding()
# 	return self

# func can_drop_data(position, data):
# 	if data.item == null:
# 		return false
# 	return true

# func drop_data(position, data):
# 	data.on_released()
# 	if item == null:
# 		set_item(data.item, data.count)
# 		data.clear()
# 	else:
# 		var temp = [item, count]
# 		set_item(data.item, data.count)
# 		data.callv("set_item", temp)

# 	emit_signal("dropped_data")
