extends Camera2D

@export var default_offset := Vector2.ZERO
@export var down_offset := Vector2(0, 100)  # how far down camera moves
@export var speed := 5.0

func _ready():
	zoom = Vector2(1, 1)
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

func _process(delta):
	var target_offset := default_offset
	if Input.is_action_pressed("ui_down"):  # use your down key action
		target_offset = down_offset

	# Smoothly move the camera offset
	offset = offset.lerp(target_offset, speed * delta)
