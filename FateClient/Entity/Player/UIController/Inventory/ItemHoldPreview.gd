class_name ItemHoldPreview
extends TextureRect

var item: Item
var count := 0 setget set_count

var open_item_holders := []


func set_count(x):
	count = x
	$ItemCount.text = str(count) if count != 0 else ""
	if count <= 0:
		clear()


func set_hold_preview(i: Item, amount := 1):
	show()
	self.item = i
	self.count = amount
	texture = ItemTextureDatabase.get_item_texture(self.item.ming)


func clear():
	item = null
	hide()


func on_left_click(holder: ItemHolderBase) -> void:
	if item == null:
		if holder.item != null:
			set_hold_preview(holder.item, holder.count)
			holder.clear()
	else:
		if holder.item == null:
			holder.set_item(item, count)
			clear()
		else:
			if holder.item.ming == item.ming:
				holder.count += count
				clear()
			else:
				swap_with_holder(holder)


func swap_with_holder(holder: ItemHolderBase):
	var temp = [holder.item, holder.count]
	holder.set_item(item, count)
	callv("set_hold_preview", temp)


func on_right_click(holder: ItemHolderBase) -> void:
	if holder.item == null:
		if item != null:
			holder.set_item(item)
			self.count -= 1
	elif item == null:
		var half = int(ceil(holder.count / 2.0))
		set_hold_preview(holder.item, half)
		holder.count -= half
	else:
		if holder.item.ming != item.ming:
			swap_with_holder(holder)
		else:
			holder.count += 1
			self.count -= 1


func on_double_click(holder: ItemHolderBase) -> void:
	# print("double click")
	if item == null:
		return
	for item_holders in open_item_holders:
		for x in item_holders:
			if x.item == null:
				continue
			if x.item.ming == item.ming:
				self.count += x.count
				x.count = 0
