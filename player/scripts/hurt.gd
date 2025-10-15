extends PlayerState
class_name HurtState

const KNOCKBACK_X := 50
const KNOCKBACK_Y := -150

var HURT_SOUND: AudioStream = preload("res://Sounds/8-bit-hurt.wav")
var hurt_sfx: AudioStreamPlayer
var damage_taken: int = 0

func _play_sound(player, stream: AudioStream) -> void:
	hurt_sfx = AudioStreamPlayer.new()   # use AudioStreamPlayer2D if you want positional audio
	hurt_sfx.stream = stream
	player.add_child(hurt_sfx)
	hurt_sfx.volume_db = 0.0
	hurt_sfx.play()
	
func enter(player):
	if player.deathActive == 1:
		return
	if player.deathActive == 0:
		# Apply damage
		player.health -= damage_taken
		player.update_health_bar()
		if player.health < 1:
			player.health = 0
			player.die()
			return
	player.anim.play("hurt")
	_play_sound(player, HURT_SOUND)
	
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
	if not player.anim.is_playing() and player.deathActive == 0:
		player.velocity = Vector2.ZERO
		player.change_state(IdleState.new())
