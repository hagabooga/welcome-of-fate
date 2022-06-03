class_name DataLoader
extends Node

var db

const path := "res://Singletons/Database/"
const datas := ["enemies", "items"]


func _init(db):
	self.db = db
	for table_name in datas:
		insert_json(table_name)

	var file = File.new()
	file.open(path + "items" + ".json", File.READ)
	var json = parse_json(file.get_as_text())
	var fix = {}
	for i in range(len(json)):
		fix[i] = json[i].ming
	file.close()
	file = File.new()
	file.open(path + "fixed" + ".json", File.WRITE)
	file.store_string(to_json(fix))
	file.close()


func insert_json(table_name):
	var json := load_json(table_name)
	for i in range(len(json)):
		var row = json[i]
		row.id = i
		if row.has("stats"):
			row.erase("stats")
		db.get(table_name).insert(row)


func load_json(json_name: String) -> Array:
	var file = File.new()
	var err = file.open(path + json_name + ".json", File.READ)
	var json := []
	if err:
		print("cannot read json")
	else:
		json = parse_json(file.get_as_text())
	file.close()
	return json
