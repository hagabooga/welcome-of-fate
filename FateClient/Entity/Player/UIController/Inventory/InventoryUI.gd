class_name InventoryUI
extends Control

signal item_added(item)
signal inventory_changed

var current_hovering_item: Item = null
var held_items := {}
var current_hotkey_index := 0

onready var item_hold_preview: ItemHoldPreview
onready var hotkey_items := $HotkeysMargin/HotkeysPanel/HotkeysContainer.get_children()
onready var inventory_items := $InventoryMargin/InventoryPanel/GridContainer.get_children()
onready var inventory_margin = $InventoryMargin
onready var tooltip = $Tooltip
onready var hotkey_selection = $HotkeysMargin/HotkeysPanel/HotkeySelection


func _ready() -> void:
	inventory_margin.hide()
	item_hold_preview = load("res://Entity/Player/UIController/Inventory/ItemHoldPreview.tscn").instance()
	add_child(item_hold_preview)
	item_hold_preview.open_item_holders.append(hotkey_items)
	tooltip.visible = false
	for x in hotkey_items + inventory_items:
		x.connect("hovering", self, "on_hovering_item")
		x.connect("mouse_exited", self, "on_mouse_exited_item")
		x.connect("left_clicked", item_hold_preview, "on_left_click")
		x.connect("right_clicked", item_hold_preview, "on_right_click")
		x.connect("double_clicked", item_hold_preview, "on_double_click")

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
	get_input()
	if item_hold_preview.item != null:
		item_hold_preview.rect_position = get_global_mouse_position()
		item_hold_preview.rect_position -= item_hold_preview.rect_size / 2

	if tooltip.visible:
		tooltip.rect_position = get_global_mouse_position()
		tooltip.rect_position.y -= tooltip.rect_size.y + 32


func get_input() -> void:
	for i in range(0, len(hotkey_items)):
		var key = str(i)
		i -= 1
		if Input.is_action_just_pressed(key):
			set_hotkey_selection(i)
	if Input.is_action_just_released("scroll_up"):
		set_hotkey_selection(current_hotkey_index + 1)
	if Input.is_action_just_released("scroll_down"):
		set_hotkey_selection(current_hotkey_index - 1)
	if Input.is_action_just_pressed("inventory"):
		inventory_margin.visible = ! inventory_margin.visible
		if inventory_margin.visible:
			item_hold_preview.open_item_holders.append(inventory_items)
		else:
			item_hold_preview.open_item_holders.erase(inventory_items)


func set_hotkey_selection(i: int):
	i %= len(hotkey_items)
	current_hotkey_index = i
	hotkey_selection.rect_global_position = hotkey_items[i].rect_global_position


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
	if item == null:
		return
	tooltip.visible = true
