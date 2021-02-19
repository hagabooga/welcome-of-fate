class_name Enemy
extends Entity

var dead = false


func _ready():
	# var regex = RegEx.new()
	# regex.compile("/([a-z])([A-Z])/g")
	display_name.text = ming.capitalize()
	connect("on_hp_change", self, "update_hp_bar")
	full_hp()
	hurtbox.connect("input_event", self, "clicked")
	connect("on_hp_change", self, "check_hp")
	check_hp(max_hp, hp)


func check_hp(max_hp, hp):
	if hp <= 0:
		die()


func die():
	if dead:
		return
	dead = true
	hurtbox.disconnect("input_event", self, "clicked")
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


func take_damage(damage):
	Server.entity_take_damage(id, damage, "enemy")


func clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			take_damage(8)
