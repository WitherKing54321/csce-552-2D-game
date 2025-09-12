extends PlayerState
class_name FightState

@onready var hurtbox = $AnimatedSprite2D/Hurtbox

var combo_step := 1
var swing_timer := 0.0
var input_window := 0.15  # time after swing to allow next input
var input_buffered := false

func enter(player):
	combo_step = 1
	_start_swing(player)


func physics_update(player, delta):
	swing_timer -= delta

	# Detect a button *press* (not hold)
	if Input.is_action_just_pressed("fight"):
		if swing_timer > 0.0:
			# Button pressed during current swing → buffer next attack
			input_buffered = true

	# When swing ends
	if swing_timer <= 0.0:
		if input_buffered:
			# Go to next combo step
			_next_combo(player)
			input_buffered = false
		else:
			# Give the player a small grace period to mash again
			input_window -= delta
			if input_window <= 0.0:
				_return_to_default(player)


func _start_swing(player):
	# Play animation for this combo step
	match combo_step:
		1: player.anim.play("fight1")
		2: player.anim.play("fight2")
		3: player.anim.play("fight3")

	# Enable hurtbox
	_enable_hurtbox(player)

	# Reset timers (0.33s = 3 swings per sec)
	swing_timer = 0.25
	input_window = 0.15


func _next_combo(player):
	# Step through 1 → 2 → 3 → back to 1
	combo_step = combo_step % 3 + 1
	_start_swing(player)


func _enable_hurtbox(player):
	var hurtbox = player.get_node("Hurtbox")
	hurtbox.monitoring = true
	print("Hurtbox enabled")


func _disable_hurtbox(player):
	var hurtbox = player.get_node("Hurtbox")
	hurtbox.monitoring = false
	print("Hurtbox disabled")


func _return_to_default(player):
	_disable_hurtbox(player)
	if player.is_on_floor():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			player.change_state(RunState.new())
		else:
			player.change_state(IdleState.new())
	else:
		player.change_state(JumpState.new())
