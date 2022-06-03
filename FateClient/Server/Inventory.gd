class_name Inventory
extends Node

signal received_inventory_data

var data: Array

remote func receive_inventory_data(data: Array):
	self.data = data
	emit_signal("received_inventory_data", data)
