extends PlayerState
class_name RunState

func enter(player):
	player.anim.play("run")

func physics_update(player, delta):
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED
	

	if dir == 0:
		player.change_state(IdleState.new())
	elif Input.is_action_just_pressed("move_jump") and player.is_on_floor():
		player.change_state(JumpState.new())
