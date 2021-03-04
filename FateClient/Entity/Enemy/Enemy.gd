class_name Enemy
extends Entity

var move_direction = Enums.DIRECTION_DOWN
var current_animation = Enums.ANIMATION_IDLE

var anims = ["Up", "Left", "Down", "Right"]


func _ready():
	connect("on_hp_change", self, "update_hp_bar")
	full_hp()
	# connect("on_hp_change", self, "check_hp")
	check_hp(max_hp, hp)
	set_display_name(ming.capitalize())

	for i in range(len(anims)):
		load_animation_frame_coords(anims[i], i)
	anim_player.playback_speed = 4


func load_animation_frame_coords(anim_name, y_coord):
	anim_player.get_animation(anim_name).track_set_key_value(0, 0, Vector2(0, y_coord))
	anim_player.get_animation(anim_name).track_set_key_value(
		0, 1, Vector2(sprite.hframes - 1, y_coord)
	)


func _process(delta):
	if hp <= 0:
		sprite.frame_coords = Vector2(0, anims.find(Enums.direction_to_string(move_direction)))
		return
	if current_animation == Enums.ANIMATION_IDLE:
		sprite.frame_coords = Vector2(0, anims.find(Enums.direction_to_string(move_direction)))
		return
	anim_player.play(Enums.direction_to_string(move_direction))


# func walk(dir):
# 	match dir:
# 		Enums.DIRECTION_RIGHT:
# 			anim_player.play("")


func init(stats):
	print(stats)
	self.ming = stats.ming
	self.max_hp = stats.max_hp
	self.hp = stats.hp
	self.id = stats.id


# func check_hp(max_hp, hp):
# 	if hp <= 0:
# 		die()


func die():
	collisionbox.set_deferred("disabled", true)
	hurtbox.get_child(0).set_deferred("disabled", true)
	hp_bar.hide()
	$Sprite/AnimationPlayer.play("Die")
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = randi() % 5 + 2
	add_child(timer)
	timer.connect("timeout", self, "queue_free")
	timer.connect("timeout", get_tree().current_scene, "erase_enemy", [id])
	yield(get_tree().create_timer(0.2), "timeout")


func move_enemy(pos, move_dir, anim):
	global_position = pos
	move_direction = move_dir
	current_animation = anim
