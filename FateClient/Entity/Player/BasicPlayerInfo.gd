class_name BasicPlayerInfo

var username
var body
var eyes
var gender
var hair
var hair_color
var eyes_color
var color


func _init(basic_info, color):
	self.username = basic_info.username
	self.body = basic_info.body
	self.eyes = basic_info.eyes
	self.gender = basic_info.gender
	self.hair = basic_info.hair
	self.hair_color = basic_info.hair_color
	self.eyes_color = basic_info.eyes_color
	self.color = color
