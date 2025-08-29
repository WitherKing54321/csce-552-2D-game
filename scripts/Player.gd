extends CharacterBody2D

const SPEED := 250.0
const JUMP_VELOCITY := -300.0   # negative goes UP in Godot 2D
const GRAVITY := 2000.0

func _physics_process(delta):
	# Horizontal input only; Y is handled by gravity/jump
	velocity.x = Input.get_axis("move_left", "move_right") * SPEED
	#print("Left:", Input.is_action_pressed("move_left"), " | Right:", Input.is_action_pressed("move_right"))
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("move_jump"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()
