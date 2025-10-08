extends EnemyState2
class_name EnemyHurtState2

#const KNOCKBACK_X := 20
#const KNOCKBACK_Y := -70
var damage_taken: int = 0

# --- AUDIO: preload hurt sound ---
var HURT2_STREAM: AudioStream = preload("res://Sounds/ZweihanderHurt.wav")
var hurt2_sfx: AudioStreamPlayer2D

# --- exported volume (editable in Inspector) ---
@export var hurt_volume_db: float = +5.0   # 0 = normal, negative = quieter, positive = louder

func enter(Enemy2):
	print("ENTER NUCK BoB STATE")

	# Stop footsteps if they are playing
	if Enemy2.has_meta("step_sfx"):
		var run_sfx = Enemy2.get_meta("step_sfx")
		if run_sfx and run_sfx is AudioStreamPlayer2D and run_sfx.playing:
			run_sfx.stop()

	# Apply damage
	Enemy2.health -= damage_taken
	if Enemy2.health < 1:
		Enemy2.health = 0
		Enemy2.change_state(EnemyDeathState2.new())
		return

	# Play hurt animation
	Enemy2.anim.play("enemy2Hurt")

	# Play hurt sound
	if hurt2_sfx == null:
		hurt2_sfx = AudioStreamPlayer2D.new()
		hurt2_sfx.stream = HURT2_STREAM
		Enemy2.add_child(hurt2_sfx)
	hurt2_sfx.pitch_scale = randf_range(0.95, 1.05)
	hurt2_sfx.volume_db = hurt_volume_db   # apply inspector value
	hurt2_sfx.play()

func physics_update(Enemy2, delta):
	Enemy2.move_and_slide()

	# Wait until hurt anim is finished
	if not Enemy2.anim.is_playing() and Enemy2.health > 0:
		Enemy2.change_state(EnemyIdleState2.new())
