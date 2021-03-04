class_name PlayerDatabase
extends SpecificDatabase

var basic_info_columns = ["username", "body", "eyes", "hair", "eyes_color", "hair_color", "gender"]
var stats_columns = ["username", "str", "int", "agi", "luc"]


func _init(x).(x):
	pass


func get_stats(username):
	var stats = Database.db.select_rows(
		"players_stats", 'username == "%s"' % [username], stats_columns
	)
	if stats.size() == 0:
		return null

	return stats[0]


func create_stats(username):
	var info = {}
	info.username = username
	info.str = 4
	info.int = 4
	info.agi = 4
	info.luc = 4
	Database.db.insert_row("players_stats", info)


func get_basic(username):
	var basic = Database.db.select_rows(
		"players_basic_info", 'username == "%s"' % [username], basic_info_columns
	)
	if basic.size() == 0:
		return null
	basic[0].loc = Vector2(randi() % 50, randi() % 50)
	return basic[0]


func create_basic(username, data):
	data.username = username
	Database.db.insert_row("players_basic_info", data)
