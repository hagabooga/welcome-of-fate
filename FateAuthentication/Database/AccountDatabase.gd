extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db: SQLite
var db_name := "res://Database/"


func _ready():
	db = SQLite.new()
	db.path = db_name
	db.verbose_mode = true
	db.foreign_keys = true
	db.open_db()

	db.create_table(
		"accounts",
		{
			"username":
			{
				"data_type": "text",
				"not_null": true,
				"unique": true,
				"primary_key": true,
			},
			"password": {"data_type": "text", "not_null": true},
		}
	)


func get(username):
	var rows = db.select_rows("accounts", 'username == "%s"' % [username], ["username", "password"])
	if rows == []:
		return null
	return rows[0]


func create(username, password):
	var row = {}
	row.username = username
	row.password = password
	db.insert_row("accounts", row)


func exists(username):
	return false if get(username) == null else true
