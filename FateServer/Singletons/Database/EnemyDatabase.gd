class_name EnemyDatabase
var db
var column_names = ["ming", "hp", "armor", "resist", "damage"]


func _init(db):
	self.db = db


func _ready():
	Database.db.select_rows("enemies", "", ["id", "name"])


func get_enemy(id):
	return Database.db.select_rows("enemies", "id == %d" % [id], column_names)[0]
