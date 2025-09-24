extends EnemyState
class_name EnemyChaseState

# --- AUDIO: preload a loop (footsteps/armor clank) ---
var STEP_STREAM: AudioStream = preload("res://Sounds/NuckRun.wav")
var step_sfx: AudioStreamPlayer2D

func enter(Enemy):
	Enemy.anim.play("nuckWalk")
	print("Entered Chase State")

	# Create the audio player once and reuse it
	if step_sfx == null:
		step_sfx = AudioStreamPlayer2D.new()
		step_sfx.stream = STEP_STREAM
		step_sfx.autoplay = false
		step_sfx.volume_db = -6.0
		step_sfx.pitch_scale = randf_range(0.98, 1.02)
		Enemy.add_child(step_sfx)

		# If it's a WAV stream, enable looping
		if STEP_STREAM is AudioStreamWAV:
			var s := STEP_STREAM as AudioStreamWAV
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Save reference on the enemy so Hurt/Death can stop it
	Enemy.set_meta("step_sfx", step_sfx)

	# Start walking loop
	if STEP_STREAM and not step_sfx.playing:
		step_sfx.play()

func physics_update(Enemy, delta):
	if not Enemy.player:
		if step_sfx and step_sfx.playing:
			step_sfx.stop()
		return

	Enemy.dir = (Enemy.player.position - Enemy.position).normalized()
	Enemy.velocity.x = Enemy.dir.x * Enemy.speed

	# If close enough to attack, stop loop then change state
	if Enemy.position.distance_to(Enemy.player.position) < Enemy.attack_range:
		if step_sfx and step_sfx.playing:
			step_sfx.stop()
		Enemy.change_state(EnemyAttackState.new())
