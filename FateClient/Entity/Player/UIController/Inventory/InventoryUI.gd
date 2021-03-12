class_name InventoryUI
extends Control

signal item_added(item)
signal inventory_changed

var current_hovering_item: Item = null
var held_items := {}

onready var hotkey_items := $HotkeysMargin/HotkeysPanel/HotkeysContainer.get_children()
onready var tooltip = $Tooltip


func _ready() -> void:
	tooltip.visible = false
	for x in hotkey_items:
		x.connect("hovering", self, "on_hovering_item")
		x.connect("mouse_exited", self, "on_mouse_exited_item")

	for i in range(10):
		add_item(
			Item.new(
				"tomato",
				{
					"desc": "A tomato.",
					"eff_desc": "Consume item to restore 50 HP and 50 MP.",
					"cost": 135,
					"type": "plant",
					"activate": 0,
					"stats": {"hp": 50, "mp": 50}
				}
			)
		)

	for i in range(15):
		add_item(
			Item.new(
				"turnip",
				{
					"desc": "A root vegetable grown in temperate climates.",
					"eff_desc": "Consume item to restore 60 HP.",
					"cost": 125,
					"type": "plant",
					"activate": 0,
					"stats": {"hp": 60}
				}
			)
		)


func _process(delta) -> void:
	if tooltip.visible:
		tooltip.rect_position = get_global_mouse_position()
		tooltip.rect_position.y -= tooltip.rect_size.y


func add_item(item: Item) -> void:
	if item.ming in held_items:
		held_items[item.ming].count += 1
	else:
		for x in hotkey_items:
			if x.item == null:
				held_items[item.ming] = x
				x.set_item(item)
				break


func on_mouse_exited_item() -> void:
	tooltip.visible = false
	current_hovering_item = null


func on_hovering_item(item: Item) -> void:
	current_hovering_item = item
	tooltip.visible = true
