extends PlayerState
class_name GlideState

func enter(player):
	player.anim.play("glide")

func physics_update(player, delta):
	# Cap vertical velocity
	player.velocity.y = min(player.velocity.y, 50)
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED/1.5

	# Check if glide ends
	if not Input.is_action_pressed("glide") or player.is_on_floor():
		#print("TEST_TEST_TEST")
		#player.velocity.x = 0 # stop sliding horizontally
		player.anim.play("bird_disappear")
		player.change_state(IdleState.new())
