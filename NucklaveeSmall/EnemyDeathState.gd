extends NuckState
class_name NuckDeathState

func enter(nuck):
	# Stop movement
	nuck.velocity = Vector2.ZERO
	
	# Play death animation
	nuck.anim.play("death")
	#get_node("NuckCollisionShape2D").disbled = true
	# Optional: disable the hitbox so it can't interact anymore
	#if nuck.has_node("Hitbox"):
		#nuck.$Hitbox.monitoring = false
		#nuck.$Hitbox.set_deferred("disabled", true)  # prevents signal triggering

	# Optional: stop state changes
	nuck.attack = false

func physics_update(nuck, delta):
	# Just stop the Nuck from moving; gravity optional
	nuck.velocity = Vector2.ZERO
	# No state change, Nuck stays lying there
