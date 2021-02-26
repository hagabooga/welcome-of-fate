class_name PlayerDatabase
extends SpecificDatabase

var column_names = ["ming", "color", "hp", "armor", "resist"]


func _init(x).(x):
	pass


func get_player(ming):
	var stats = Database.db.select_rows("players", 'ming == "%s"' % [ming], column_names)
	if stats.size() == 0:
		return null
	return stats[0]


func create_account(player_info):
	print(player_info)
	var info = {}
	info.n = player_info.n
	info.c = player_info.c
	info.max_hp = 100
	info.hp = 100
	info.armor = 10
	info.resist = 5
	Database.db.insert_row("players", info)
