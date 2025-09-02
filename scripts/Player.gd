extends CharacterBody2D

const SPEED := 150.0
const JUMP_VELOCITY := -400.0   # negative goes UP in Godot 2D
const GRAVITY := 1500.0

@onready var sprite = $AnimatedSprite2D

var was_on_floor := false   # to detect landing

func _ready():
	sprite.play("idle")

func _physics_process(delta):
	# Horizontal input
	velocity.x = Input.get_axis("move_left", "move_right") * SPEED

	# Flip sprite depending on direction
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump input
	if is_on_floor() and Input.is_action_just_pressed("move_jump"):
		velocity.y = JUMP_VELOCITY

	# ---------------------------
	# Animation state machine
	# ---------------------------
	if not is_on_floor():
		if velocity.y < 0: # going up
			if sprite.animation != "jump":
				sprite.play("jump")
		else: # going down
			if sprite.animation != "fall":
				sprite.play("fall")
	elif velocity.x != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	move_and_slide()

	# Track landing for next frame
	was_on_floor = is_on_floor()
