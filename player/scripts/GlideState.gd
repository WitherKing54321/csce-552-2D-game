extends PlayerState
class_name GlideState

func enter(player):
	#player.anim.play("bird_appear")
	player.anim.play("glide")

func physics_update(player, delta):
	player.velocity.y = min(player.velocity.y, 50) # cap fall speed

	if not Input.is_action_pressed("glide") or player.is_on_floor():
		player.anim.play("bird_disappear")
		player.change_state(IdleState.new())
