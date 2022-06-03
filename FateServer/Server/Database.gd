class_name Database
extends Node

var db: Plugins.SQLite
var db_name := "res://Singletons/Database/"

var enemies: DatabaseTable
var player_basics: DatabaseTable
var player_stats: DatabaseTable
var player_inventories: DatabaseTable
var items: DatabaseTable


func _init():
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

	items = DatabaseTable.new(
		db,
		"items",
		{
			"id": {"data_type": "int", "primary_key": true, "not_null": true},
			"ming":
			{
				"data_type": "text",
				"not_null": true,
				"unique": true,
			},
			"base": {"data_type": "text"},
			"activate": {"data_type": "int", "not_null": true},
			"cost": {"data_type": "int", "not_null": true},
			"desc": {"data_type": "text", "not_null": true},
			"eff_desc": {"data_type": "text"},
			"placeable": {"data_type": "int"},
			"type": {"data_type": "text", "not_null": true},
			"energy": {"data_type": "int"},
			"hack": {"data_type": "int"},
			"capacity": {"data_type": "int"},
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

	player_inventories = DatabaseTable.new(
		db,
		"player_inventories",
		{
			"username":
			{
				"data_type": "text",
				"not_null": true,
				"unique": true,
				"foreign_key": "player_basics.username"
			},
			"item_id": {"data_type": "int", "not_null": true, "foreign_key": "items.id"},
			"quantity": {"data_type": "int", "not_null": true},
			"child_index": {"data_type": "int", "not_null": true},
		},
		"username"
	)

	DataLoader.new(self)
