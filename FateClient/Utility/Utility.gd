extends Node
# Return enum DIRECTION
static func get_direction(rad, cutoff = 55) -> int:
	var angle = rad2deg(rad)
	var opp = 180 - cutoff
	var direction = Enums.DIRECTION_UP
	if -cutoff < angle and angle < cutoff:
		direction = Enums.DIRECTION_LEFT
	elif -opp < angle and angle <= -cutoff:
		direction = Enums.DIRECTION_DOWN
	elif (-180 <= angle and angle <= -opp) or (opp < angle and angle <= 180):
		direction = Enums.DIRECTION_RIGHT
	return direction
