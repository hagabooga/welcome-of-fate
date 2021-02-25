class_name Enemy
extends KinematicBody2D

export (int) var id
# var ming
# var hp
# var armor
# var resist
# var damage
# var time_out = 1
# var spawn_id
# var loc
# var state = Enums.ENTITY_ALIVE

# func init(spawn_id, loc):
# 	var stats = Database.enemies.get_enemy(enemy_id)
# 	self.ming = stats.ming
# 	self.hp = stats.hp
# 	self.armor = stats.armor
# 	self.resist = stats.resist
# 	self.damage = stats.damage
# 	self.spawn_id = spawn_id
# 	self.loc = loc

# func to_dict():
# 	var dict = {}
# 	dict.ming = ming
# 	dict.hp = hp
# 	dict.armor = armor
# 	dict.resist = resist
# 	dict.damage = damage
# 	dict.id = spawn_id
# 	dict.loc = loc
# 	dict.state = state
# 	return dict
