extends Camera2D
func _ready():
	zoom = Vector2(1, 1) # zoom in a bit
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
