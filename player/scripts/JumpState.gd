extends PlayerState
class_name JumpState

func enter(player):
	# Handle jump or double jump
	if not player.has_double_jumped:
		player.velocity.y = player.JUMP_VELOCITY
		player.anim.play("jump")
		player.has_double_jumped = false
	else:
		player.velocity.y = player.DOUBLE_JUMP_VELOCITY
		#player.anim.play("double_jump")
		player.has_double_jumped = true

func physics_update(player, delta):
	# Horizontal movement
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED

	# Glide functionality
	if player.velocity.y > 0 and Input.is_action_pressed("glide"):
		player.change_state(GlideState.new())
		return
	if player.velocity.y > 0 and not Input.is_action_just_pressed("glide"):
		player.anim.play("fall")

	# Double jump input
	if Input.is_action_just_pressed("move_jump") and not player.has_double_jumped:
		player.velocity.y = player.DOUBLE_JUMP_VELOCITY
		player.anim.play("double_jump")
		player.has_double_jumped = true

	# Landed
	elif player.is_on_floor():
		player.has_double_jumped = false  # reset on landing
		player.change_state(IdleState.new())
