extends EnemyState
class_name EnemyDeathState

var timer = 1.0

func enter(Enemy):
	print("enter nuck deathstate")
	# Stop movement
	#Enemy.velocity = Vector2.ZERO
	# Play death animation
	Enemy.anim.play("nuckDeath")
	#Enemy.attack = false

func physics_update(Enemy, delta):
	# Just stop the Nuck from moving; gravity optional
	timer -= delta
	Enemy.velocity = Vector2.ZERO
	if timer <= 0.0:
		Enemy.queue_free()
	# No state change, Nuck stays lying there
