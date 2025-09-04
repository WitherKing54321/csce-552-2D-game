extends CharacterBody2D

const SPEED := 150.0
const JUMP_VELOCITY := -300.0
const GRAVITY := 1500.0
const GLIDE_MULTIPLIER := 0.3   # 20% gravity while gliding (tweak to taste)

@onready var sprite := $AnimatedSprite2D

var was_on_floor := false

# --- Double jump control ---
var max_jumps := 2
var jumps_left := 2
# ----------------------------

# --- Glide control ---
var is_gliding := false
var has_glided := false
# ---------------------

func _ready() -> void:
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	# Horizontal input
	var input_dir := Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * SPEED

	# Flip sprite depending on direction (swap true/false if your art faces the other way)
	if velocity.x > 0.0:
		sprite.flip_h = true
	elif velocity.x < 0.0:
		sprite.flip_h = false

	# Gravity (normal unless gliding)
	if not is_on_floor():
		var g := GRAVITY * (GLIDE_MULTIPLIER if is_gliding else 1.0)
		velocity.y += g * delta
	else:
		jumps_left = max_jumps
		is_gliding = false

	# Jump input
	if Input.is_action_just_pressed("move_jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		# Jump animations
		if jumps_left == max_jumps - 1:
			sprite.play("jump")
		elif jumps_left == 0:
			sprite.play("double_jump")

	# Glide input handling
	if Input.is_action_pressed("glide"):
		if is_on_floor():
			is_gliding = false
		elif not is_on_floor() and velocity.y > 0:
			is_gliding = true
			sprite.play("glide")
	else:
		is_gliding = false

	# Animation state machine (don’t override glide)
	if not is_on_floor() and not is_gliding:
		if velocity.y < 0.0:
			if sprite.animation not in ["jump", "double_jump"]:
				sprite.play("jump")
		else:
			if sprite.animation != "fall":
				sprite.play("fall")
	elif not is_gliding:
		if velocity.x != 0.0:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")

	# Godot 4: no-arg move_and_slide(), uses this.velocity internally
	move_and_slide()

	was_on_floor = is_on_floor()
