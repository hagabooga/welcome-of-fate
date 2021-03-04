extends KinematicBody2D

var instance_id
var hp

onready var hurtbox = $Hurtbox
onready var collisionbox = $Collisionbox


func init(player_id, loc, data):
	self.instance_id = player_id
	global_position = loc
	hp = 100


func die():
	collisionbox.disabled = true
