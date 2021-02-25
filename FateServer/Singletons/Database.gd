extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db: SQLite
var db_name := "res://Server/Databases/"

var enemies


func _ready():
	db = SQLite.new()
	db.path = db_name
	db.verbose_mode = true
	db.foreign_keys = true
	db.open_db()
	db.create_table(
		"enemies",
		{
			"id": {"data_type": "int", "primary_key": true, "not_null": true},
			"ming": {"data_type": "text", "not_null": true, "unique": true},
			"hp": {"data_type": "int", "not_null": true},
			"armor": {"data_type": "int", "not_null": true},
			"resist": {"data_type": "int", "not_null": true},
			"damage": {"data_type": "int", "not_null": true},
		}
	)

	var enemies = File.new()
	enemies.open("res://Singletons/Database/Enemies.json", File.READ)
	enemies = parse_json(enemies.get_as_text())
	print(enemies)
	for i in range(len(enemies)):
		enemies[i].id = i
		db.insert_row("enemies", enemies[i])
	print(db.select_rows("enemies", "", ["id", "hp", "ming"]))

	var enemies = EnemyDatabase.new(db)
