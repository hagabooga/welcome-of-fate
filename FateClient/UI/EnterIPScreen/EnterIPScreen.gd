extends Control

onready var title = $HBoxContainer/VBoxContainer/Title
onready var title_timer = $HBoxContainer/VBoxContainer/Title/Timer
onready var ip_address = $HBoxContainer/VBoxContainer/IPAddress
onready var ok_button = $HBoxContainer/VBoxContainer/HBoxContainer/OKButton
onready var ok_button_timer = $HBoxContainer/VBoxContainer/HBoxContainer/OKButton/Timer
onready var reset_button = $HBoxContainer/VBoxContainer/HBoxContainer/ResetButton
onready var username = $HBoxContainer/VBoxContainer/Username
onready var password = $HBoxContainer/VBoxContainer/Password
onready var confirm_password = $HBoxContainer/VBoxContainer/ConfirmPassword
onready var new_account_check = $HBoxContainer/VBoxContainer/HBoxContainer/NewAccountCheck
onready var error_display = $HBoxContainer/VBoxContainer/ErrorDisplay
onready var error_display_tween = $HBoxContainer/VBoxContainer/ErrorDisplay/Tween

var logged_in = false
var server


func init(server):
	self.server = server


func _ready():
	print(server)
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
	if new_account_check.pressed:
		if username.text == "":
			show_error("Please provide a valid username!")
		elif password.text == "":
			show_error("Please provide a valid password!")
		elif confirm_password.text == "":
			show_error("Please confirm your password!")
		elif password.text != confirm_password.text:
			show_error("Passwords do not match!")
		elif password.text.length() <= 6:
			show_error("Passwords must contain at least 7 characters")
		else:
			if ip_address.text == "":
				Gateway.connect_to_server(self, username.text, password.text, true)
			elif not ip_address.text.is_valid_ip_address():
				show_error("Not a valid IP adrress!")
			else:
				Gateway.connect_to_server(self, username.text, password.text, true, ip_address.text)
	elif not logged_in:
		if username.text == "" or password.text == "":
			show_error("Please enter a valid username/password")
			return
		else:
			if ip_address.text == "":
				print("local host")
				Gateway.connect_to_server(self, username.text, password.text)
			elif not ip_address.text.is_valid_ip_address():
				show_error("Not a valid IP adrress!")
				return

			else:
				print("external ip")
				Gateway.connect_to_server(
					self, username.text, password.text, false, ip_address.text
				)
			title_timer.start()
	disable_ui(true)


func reset_button_pressed():
	username.text = ""
	ip_address.text = ""
	password.text = ""
	confirm_password.text = ""
	# new_account_check.pressed = false


func new_account_checked_toggled(yes):
	# color_picker.visible = yes
	title.text = "Create an Account" if yes else "Login"
	confirm_password.visible = yes
	reset_button_pressed()


func show_error(text):
	error_display.text = text
	error_display_tween.stop_all()
	change_error_text_color_helper(Color.white)
	error_display_tween.interpolate_method(
		self, "change_error_text_color_helper", Color.white, Color.transparent, 1, 0, 2, 0.5
	)
	error_display_tween.start()
	ok_button_timer.start()


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
	confirm_password.editable = ! yes
	new_account_check.disabled = yes


func on_failed_connect_to_server():
	show_error("Failed to connect to the server!")
	disable_ui(false)
	title.text = "Join a Server"
	title_timer.stop()


func on_received_account_request(result):
	match result:
		OK:
			show_error("Account created. Please log in.")
			reset_button_pressed()
			new_account_check.pressed = false
		FAILED:
			show_error("Could not create the account!")
		ERR_ALREADY_EXISTS:
			show_error("Username already exists!")
	title_timer.stop()


func on_login_received(result, token):
	match result:
		OK:
			server.database.token = token
			title_timer.start()
			title.text = "Login"
			if ip_address.text == "":
				server.connect_to_server(self)
			else:
				server.connect_to_server(self, ip_address.text)

		FAILED:
			show_error("Please provide correct username/password!")
			ok_button_timer.start()
			title_timer.stop()
			title.text = "Login"
