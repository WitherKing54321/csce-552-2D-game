extends PlayerState
class_name HurtState

const KNOCKBACK_X := 50
const KNOCKBACK_Y := -150

func enter(player):
	# Play hurt animation
	player.anim.play("hurt")
	
	# Knockback direction: opposite of facing
	var direction = -1 if player.anim.flip_h else 1
	
	player.velocity.x = KNOCKBACK_X * direction
	player.velocity.y = KNOCKBACK_Y

func physics_update(player, delta):
	# Apply gravity
	player.velocity.y += player.GRAVITY * delta
	
	# Move player
	player.move_and_slide()
	
	# Wait until the hurt animation is done
	if not player.anim.is_playing():
		player.velocity = Vector2.ZERO
		player.change_state(IdleState.new())
