extends NuckState
class_name NuckChaseState

func enter(nuck):
		nuck.anim.play("walk")
		print("Entered Chase State")

func physics_update(nuck, delta):
	if not nuck.player:
		return
	var dir = (nuck.player.position - nuck.position).normalized()
	nuck.velocity.x = dir.x * nuck.speed

	if nuck.position.distance_to(nuck.player.position) < nuck.attack_range:
		nuck.change_state(NuckAttackState.new())
