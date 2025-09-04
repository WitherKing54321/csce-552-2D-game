extends PlayerState
class_name Dash

var dash_time := 0.2
var timer := 0.0

func enter(player):
	player.anim.play("dash")
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if dir == 0: dir = player.facing_dir
	player.velocity.x = dir * 600
	player.velocity.y = 0
	timer = dash_time

func physics_update(player, delta):
	timer -= delta
	if timer <= 0:
		player.change_state(IdleState.new())
