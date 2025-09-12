extends EnemyState
class_name EnemyHurtState

const KNOCKBACK_X := 20
const KNOCKBACK_Y := -70
var damage_taken: int = 0

func enter(Enemy):
	print("ENTER NUCK HURT STATE")
	# Apply damage
	Enemy.health -= damage_taken
	print(Enemy.health)
	if Enemy.health < 1:
		print("debug 01")
		Enemy.health = 0
		print("debug 02")
		Enemy.change_state(EnemyDeathState.new())
		return
	# Play hurt animation
	Enemy.anim.play("nuckHurt")
	# Knockback direction: opposite of facing
	var direction = -1 if Enemy.anim.flip_h else 1
	Enemy.velocity.x = KNOCKBACK_X * direction
	Enemy.velocity.y = KNOCKBACK_Y



func physics_update(Enemy, delta):
	# Move the Nuck
	Enemy.move_and_slide()
	# Wait until the hurt animation is done
	if not Enemy.anim.is_playing():
		#nuck.velocity = Vector2.ZERO
		if Enemy.health > 0:
			# Go back to idle/chase state after being hurt
			Enemy.change_state(EnemyIdleState.new())
