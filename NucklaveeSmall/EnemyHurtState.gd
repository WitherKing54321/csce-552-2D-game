extends NuckState
class_name NuckHurtState

const KNOCKBACK_X := 20
const KNOCKBACK_Y := -70

var damage_taken: int = 0

func enter(nuck):
	print("ENTER NUCK HURT STATE")
	# Apply damage
	nuck.health -= damage_taken
	if nuck.health < 1:
		nuck.health = 0
		nuck.change_state(NuckDeathState.new())
		return
	# Play hurt animation
	nuck.anim.play("hurt")
	# Knockback direction: opposite of facing
	var direction = -1 if nuck.anim.flip_h else 1
	nuck.velocity.x = KNOCKBACK_X * direction
	nuck.velocity.y = KNOCKBACK_Y



func physics_update(nuck, delta):
	print("nuck hurt physics update")
	print(nuck.health)
	# Move the Nuck
	nuck.move_and_slide()
	# Wait until the hurt animation is done
	if not nuck.anim.is_playing():
		#nuck.velocity = Vector2.ZERO
		if nuck.health > 0:
			# Go back to idle/chase state after being hurt
			nuck.change_state(NuckIdleState.new())
