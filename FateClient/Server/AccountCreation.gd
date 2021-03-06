class_name AccountCreation
extends Node

# signal account_creation_received(error)


func _init():
	name = "AccountCreation"


func request_new_account(data: Dictionary) -> void:
	rpc_id(1, "receive_request_create_account", data)

# remote func receive_account_creation(error: int) -> void:
# 	emit_signal("account_creation_received", error)
