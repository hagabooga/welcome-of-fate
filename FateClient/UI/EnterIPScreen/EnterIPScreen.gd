extends Control

onready var title = $HBoxContainer/VBoxContainer/Title
onready var title_timer = $HBoxContainer/VBoxContainer/Title/Timer
onready var ip_address = $HBoxContainer/VBoxContainer/IPAddress
onready var ok_button = $HBoxContainer/VBoxContainer/HBoxContainer/OKButton
onready var ok_button_timer = $HBoxContainer/VBoxContainer/HBoxContainer/OKButton/Timer
onready var reset_button = $HBoxContainer/VBoxContainer/HBoxContainer/ResetButton
onready var username = $HBoxContainer/VBoxContainer/Username
onready var password = $HBoxContainer/VBoxContainer/Password
onready var color_picker = $HBoxContainer/ColorPicker
onready var new_account_check = $HBoxContainer/VBoxContainer/HBoxContainer/NewAccountCheck
onready var error_display = $HBoxContainer/VBoxContainer/ErrorDisplay
onready var error_display_tween = $HBoxContainer/VBoxContainer/ErrorDisplay/Tween

var logged_in = false


func _ready():
	title.text = "Login"
	ip_address.connect("text_entered", self, "ip_address_text_entered")
	ok_button.connect("pressed", self, "ok_button_pressed")
	ok_button_timer.connect("timeout", self, "disable_ui", [false])
	reset_button.connect("pressed", self, "reset_button_pressed")
	new_account_check.connect("toggled", self, "new_account_checked_toggled")


func _process(delta):
	if not title_timer.is_stopped():
		title.text = "Connecting" + ".".repeat(int(4 - title_timer.time_left))


func ip_address_text_entered(text):
	ok_button_pressed()


func ok_button_pressed():
	if not logged_in:
		if username.text == "" or password.text == "":
			show_error("Please enter a valid username/password")
		else:
			if ip_address.text == "":
				Gateway.connect_to_server(self, username.text, password.text)
			elif not ip_address.text.is_valid_ip_address():
				show_error("Not a valid IP adrress!")
				return

			else:
				Gateway.connect_to_server(self, username.text, password.text, ip_address.text)
			disable_ui(true)
			title_timer.start()
	# if not connected_to_server:
	# 	if ip_address.text == "":
	# 		Server.connect_to_server(self)
	# 		title_timer.start()
	# 	elif not ip_address.text.is_valid_ip_address():
	# 		show_error("Not a valid IP adrress!")
	# 		return
	# 	else:
	# 		Server.connect_to_server(self, ip_address.text)
	# 		title_timer.start()
	# else:
	# 	if new_account_check.pressed:
	# 		Server.try_create_new_account(self, username.text, color_picker.color)
	# 	else:
	# 		Server.try_login(self, username.text)
	disable_ui(true)


func reset_button_pressed():
	username.text = ""
	ip_address.text = ""
	password.text = ""
	new_account_check.pressed = false
	color_picker.color = Color.white


func new_account_checked_toggled(yes):
	# color_picker.visible = yes
	title.text = "Create an Account" if yes else "Login"


func show_error(text):
	error_display.text = text
	error_display_tween.stop_all()
	change_error_text_color_helper(Color.white)
	error_display_tween.interpolate_method(
		self, "change_error_text_color_helper", Color.white, Color.transparent, 1, 0, 2, 0.5
	)
	error_display_tween.start()


func change_error_text_color_helper(color):
	error_display.add_color_override("font_color", color)


func on_successful_connect_to_server():
	show_error("Successfuly connected to the server!")


func disable_ui(yes):
	ok_button.disabled = yes
	reset_button.disabled = yes
	ip_address.editable = ! yes
	username.editable = ! yes
	password.editable = ! yes
	new_account_check.disabled = yes


func on_failed_connect_to_server():
	show_error("Failed to connect to the server!")
	disable_ui(false)
	title.text = "Join a Server"
	title_timer.stop()


func on_account_creation_received(error):
	match error:
		OK:
			show_error("Account successfully created!")

		FAILED:
			show_error("Account already exists!")


func on_login_received(result, token):
	match result:
		OK:
			Server.token = token
			title_timer.start()
			title.text = "Login"
			if ip_address.text == "":
				Server.connect_to_server(self)
			else:
				Server.connect_to_server(self, ip_address.text)

		FAILED:
			show_error("Please provide correct username/password!")
			ok_button_timer.start()
			title_timer.stop()
			title.text = "Login"
