extends EnemyState
class_name EnemyHurtState

const KNOCKBACK_X := 20
const KNOCKBACK_Y := -70
var damage_taken: int = 0

# --- AUDIO: preload hurt sound ---
var HURT_STREAM: AudioStream = preload("res://Sounds/NuckHurt.wav")
var hurt_sfx: AudioStreamPlayer2D

# --- exported volume (editable in Inspector) ---
@export var hurt_volume_db: float = +5.0   # 0 = normal, negative = quieter, positive = louder

func enter(Enemy):
	print("ENTER NUCK HURT STATE")

	# Stop footsteps if they are playing
	if Enemy.has_meta("step_sfx"):
		var run_sfx = Enemy.get_meta("step_sfx")
		if run_sfx and run_sfx is AudioStreamPlayer2D and run_sfx.playing:
			run_sfx.stop()

	# Apply damage
	Enemy.health -= damage_taken
	if Enemy.health < 1:
		Enemy.health = 0
		Enemy.change_state(EnemyDeathState.new())
		return

	# Play hurt animation
	Enemy.anim.play("nuckHurt")

	# Play hurt sound
	if hurt_sfx == null:
		hurt_sfx = AudioStreamPlayer2D.new()
		hurt_sfx.stream = HURT_STREAM
		Enemy.add_child(hurt_sfx)
	hurt_sfx.pitch_scale = randf_range(0.95, 1.05)
	hurt_sfx.volume_db = hurt_volume_db   # apply inspector value
	hurt_sfx.play()

	# Knockback direction: opposite of facing
	var direction = -1 if Enemy.anim.flip_h else 1
	Enemy.velocity.x = KNOCKBACK_X * direction
	Enemy.velocity.y = KNOCKBACK_Y

func physics_update(Enemy, delta):
	Enemy.move_and_slide()

	# Wait until hurt anim is finished
	if not Enemy.anim.is_playing() and Enemy.health > 0:
		Enemy.change_state(EnemyIdleState.new())
