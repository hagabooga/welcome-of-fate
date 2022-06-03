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
	eff_desc = data.eff_desc if data.eff_desc != null else ""
	cost = data.cost
	type = data.type
	act = data.activate
	placeable = data.placeable != null 
	base = data.base if data.base != null else "" 
