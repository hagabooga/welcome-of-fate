class_name EnemyDatabase
extends SpecificDatabase

var column_names = ["ming", "hp", "armor", "resist", "damage"]


func _init(x).(x):
	pass


func get_enemy(id):
	var stats = Database.db.select_rows("enemies", "id == %d" % [id], column_names)[0]
	stats.max_hp = stats.hp
	return stats
