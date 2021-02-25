class_name Enemy
extends Entity


func _ready():
	# var regex = RegEx.new()
	# regex.compile("/([a-z])([A-Z])/g")
	display_name.text = ming.capitalize()
	connect("on_hp_change", self, "update_hp_bar")
	full_hp()
	connect("on_hp_change", self, "check_hp")
	check_hp(max_hp, hp)
	set_display_name(ming.capitalize())


func check_hp(max_hp, hp):
	if hp <= 0:
		die()


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

# func take_damage(damage):
# 	Server.entity_take_damage(id, damage, "enemy")
