class_name Inventory
extends Node

var db: Database
var state_processing: StateProcessing


func _init(db: Database, state_processing: StateProcessing):
	self.db = db
	self.state_processing = state_processing


func send_inventory_data(player_id):
	var data = db.player_inventories.select(state_processing.connected_players[player_id], true)
	data = data.duplicate()
	for x in data:
		x.item = db.items.select(x.item_id)
	print("data", data, "length: ", len(data))
	rpc_id(player_id, "receive_inventory_data", data)
