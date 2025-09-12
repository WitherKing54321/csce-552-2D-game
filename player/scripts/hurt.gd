extends PlayerState
class_name HurtState

const KNOCKBACK_X := 50
const KNOCKBACK_Y := -150

var damage_taken: int = 0

func enter(player):
	print("ENTER HURT STATE")

	# Apply damage
	player.health -= damage_taken
	print(player.health)
	if player.health < 1:
		player.health = 0
		player.die()
		return
	player.update_health_bar()

	# Play hurt animation
	player.anim.play("hurt")

	# Knockback direction: opposite of facing
	var direction = -1 if player.anim.flip_h else 1
	player.velocity.x = KNOCKBACK_X * direction
	player.velocity.y = KNOCKBACK_Y
	#print(player.health)

func physics_update(player, delta):
	# Apply gravity
	player.velocity.y += player.GRAVITY * delta
	
	# Move player
	player.move_and_slide()
	
	# Wait until the hurt animation is done
	if not player.anim.is_playing():
		player.velocity = Vector2.ZERO
		if player.health > 0:
			player.change_state(IdleState.new())
