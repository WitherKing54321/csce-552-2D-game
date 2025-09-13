extends EnemyState
class_name EnemyDeathState

func enter(Enemy):
	print("enter nuck deathstate")
	# Stop movement
	#Enemy.velocity = Vector2.ZERO
	# Play death animation
	Enemy.anim.play("nuckDeath")
	#Enemy.attack = false

func physics_update(Enemy, delta):
	# Just stop the Nuck from moving; gravity optional
	Enemy.velocity = Vector2.ZERO
	# No state change, Nuck stays lying there
