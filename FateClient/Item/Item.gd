class_name Item
extends Object

var ming: String
var desc: String
var eff_desc: String
var cost: int
var type: String
var base: String
var act: int
var placeable: bool


func _init(m: String, data: Dictionary):
	self.ming = m
	desc = data.desc
	eff_desc = data.eff_desc if data.has("eff_desc") else ""
	cost = data.cost
	type = data.type
	act = data.activate if data.has("activate") else -1
	placeable = data.placeable if data.has("placeable") else false
	base = data.base if data.has("base") else ""
