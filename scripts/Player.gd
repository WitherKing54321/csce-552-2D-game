extends CharacterBody2D

const SPEED := 150.0
const JUMP_VELOCITY := -300.0
const GRAVITY := 1500.0
const GLIDE_GRAVITY := 1.0   # reduced gravity while gliding

@onready var sprite = $AnimatedSprite2D

var was_on_floor := false

# --- Double jump control ---
var max_jumps := 2
var jumps_left := 2
# ----------------------------

# --- Glide control ---
var is_gliding := false
# ---------------------

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

	# Gravity (normal unless gliding)
	if not is_on_floor():
		if is_gliding:
			velocity.y += GLIDE_GRAVITY * delta
		else:
			velocity.y += GRAVITY * delta

	# Reset jumps when on floor
	if is_on_floor():
		jumps_left = max_jumps
		is_gliding = false  # reset glide when landed

	# Jump input
	if Input.is_action_just_pressed("move_jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

		# --- Jump animations ---
		if jumps_left == max_jumps - 1:
			sprite.play("jump")
		elif jumps_left == 0:
			sprite.play("double_jump")
		# -----------------------

	# -------------------------
	# Glide input handling
	# -------------------------
		while Input.is_action_pressed("glide") and not is_on_floor():
			sprite.play("glide")

	# -------------------------
	# Animation state machine
	# -------------------------
	if not is_on_floor() and not is_gliding:
		if velocity.y < 0:
			if sprite.animation not in ["jump", "double_jump"]:
				sprite.play("jump")
		else:
			if sprite.animation != "fall":
				sprite.play("fall")
	elif not is_gliding:  # don’t override glide animations
		if velocity.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")

	move_and_slide()

	was_on_floor = is_on_floor()
