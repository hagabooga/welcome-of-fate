class_name Database
extends Node

var db: Plugins.SQLite
var db_name := "res://Singletons/Database/"

var enemies: DatabaseTable
var player_basics: DatabaseTable
var player_stats: DatabaseTable


func _init():
	name = "Database"
	db = Plugins.SQLite.new()
	db.path = db_name
	# db.verbose_mode = true
	db.foreign_keys = true
	db.open_db()

	enemies = DatabaseTable.new(
		db,
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

	player_basics = DatabaseTable.new(
		db,
		"player_basics",
		{
			"username":
			{
				"data_type": "text",
				"not_null": true,
				"unique": true,
				"primary_key": true,
			},
			"body": {"data_type": "text", "not_null": true},
			"eyes": {"data_type": "text", "not_null": true},
			"hair": {"data_type": "text", "not_null": true},
			"eyes_color": {"data_type": "text", "not_null": true},
			"hair_color": {"data_type": "text", "not_null": true},
			"gender": {"data_type": "int", "not_null": true},
		}
	)

	player_stats = DatabaseTable.new(
		db,
		"players_stats",
		{
			"username":
			{
				"data_type": "text",
				"not_null": true,
				"unique": true,
				"primary_key": true,
				"foreign_key": "player_basics.username"
			},
			"str": {"data_type": "int", "not_null": true},
			"int": {"data_type": "int", "not_null": true},
			"agi": {"data_type": "int", "not_null": true},
			"luc": {"data_type": "int", "not_null": true},
		}
	)
