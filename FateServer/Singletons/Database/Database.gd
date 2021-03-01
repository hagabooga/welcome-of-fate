extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db: SQLite
var db_name := "res://Singletons/Database/"

var enemies: EnemyDatabase
var players: PlayerDatabase


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

	db.create_table(
		"players_basic_info",
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

	db.create_table(
		"players_stats",
		{
			"username":
			{
				"data_type": "text",
				"not_null": true,
				"unique": true,
				"primary_key": true,
				"foreign_key": "players_basic_info.username"
			},
			"str": {"data_type": "int", "not_null": true},
			"int": {"data_type": "int", "not_null": true},
			"agi": {"data_type": "int", "not_null": true},
			"luc": {"data_type": "int", "not_null": true},
		}
	)

	var enemy_data = File.new()
	enemy_data.open("res://Singletons/Database/Enemies.json", File.READ)
	enemy_data = parse_json(enemy_data.get_as_text())
	for i in range(len(enemy_data)):
		enemy_data[i].id = i
		db.insert_row("enemies", enemy_data[i])
	# print(db.select_rows("enemies", "", ["id", "hp", "ming"]))
	enemies = EnemyDatabase.new(db)
	players = PlayerDatabase.new(db)
