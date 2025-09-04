extends PlayerState
class_name IdleState

func enter(player):
	player.anim.play("idle")
	player.has_double_jumped = false

func physics_update(player, delta):
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		player.change_state(RunState.new())
	elif Input.is_action_just_pressed("move_jump") and player.is_on_floor():
		player.change_state(JumpState.new())
