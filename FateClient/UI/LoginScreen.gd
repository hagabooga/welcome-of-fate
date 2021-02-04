extends Control

onready var username_edit: LineEdit = $Panel/VBoxContainer/UsernameEdit
onready var password_edit: LineEdit = $Panel/VBoxContainer/PasswordEdit
onready var login_button: Button = $Panel/VBoxContainer/LoginButton
onready var create_account_button: Button = $Panel/VBoxContainer/CreateAccountButton


func _ready():
	login_button.connect("pressed", self, "login")
	create_account_button.connect("pressed", self, "create_account")


func login():
	var username = username_edit.text
	var password = password_edit.text
	Gateway.connect_to_server(username, password)
	print("login pressed: ", username, " ", password)


func create_account():
	print("create account pressed")
