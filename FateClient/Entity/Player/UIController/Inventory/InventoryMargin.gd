extends MarginContainer

onready var panel: Panel = $InventoryPanel
onready var grid: GridContainer = $InventoryPanel/GridContainer

# const slots := 50

# set_item_holder()
# $GridContainer.columns = item_column_size
# $Label.text = list_name

# func set_item_holder():
# 	item_holder = load("res://ui/inventory/InventoryItemHolder.tscn")

# func set_holder_size(val):
# 	size = val
# 	for x in range(size):
# 		$GridContainer.get_child(x).visible = true
# 	for x in range(size, actual_slots):
# 		#("YO")
# 		$GridContainer.get_child(x).visible = false
# 	resize_to_holder_amount(Control.PRESET_CENTER)

# func resize_to_holder_amount(preset):
# 	rect_size.x = 32 * grid.columns + 10
# 	rect_size.y = 32 * (ceil(size / float(item_column_size))) + 10
# 	rect_position.y -= rect_size.y

# 	set_anchors_and_margins_preset(preset, 3)

# func get_holders() -> Array:
# 	return $GridContainer.get_children()

# func add_item(item: Item):
# 	var first_null = null
# 	for holder in $GridContainer.get_children():
# 		if first_null == null and holder.item == null:
# 			first_null = holder
# 			#("wow")
# 		else:
# 			if holder.item != null and holder.item.ming == item.ming:
# 				holder.count += 1
# 				return
# 	first_null.set_item(item)
