extends Control

onready var ip_address = $VBoxContainer/IPAddress
onready var ok_button = $VBoxContainer/HBoxContainer/OKButton
onready var clear_button = $VBoxContainer/HBoxContainer/ClearButton


func _ready():
	ip_address.connect("text_entered", self, "ip_address_text_entered")
	ok_button.connect("pressed", self, "ok_button_pressed")
	clear_button.connect("pressed", self, "clear_button_pressed")


func _process(delta):
	ip_address.editable = ! Server.waiting_for_connection
	ok_button.disabled = Server.waiting_for_connection
	clear_button.disabled = Server.waiting_for_connection


func ip_address_text_entered(text):
	ok_button_pressed()


func ok_button_pressed():
	if ip_address.text == "":
		Server.connect_to_server()
		return
	if not ip_address.text.is_valid_ip_address():
		print("not valid ip")
		return
	Server.connect_to_server(ip_address.text)


func clear_button_pressed():
	ip_address.text = ""
