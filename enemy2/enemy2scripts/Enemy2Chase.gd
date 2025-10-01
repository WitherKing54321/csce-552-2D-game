extends EnemyState2
class_name EnemyChaseState2

# --- AUDIO: preload a loop (footsteps/armor clank) ---
var STEP_STREAM: AudioStream = preload("res://Sounds/NuckRun.wav")
var step_sfx: AudioStreamPlayer2D

func enter(Enemy2):
	Enemy2.anim.play("enemy2Chase")
	print("Entered Chase State")

	# Create the audio player once and reuse it
	if step_sfx == null:
		step_sfx = AudioStreamPlayer2D.new()
		step_sfx.stream = STEP_STREAM
		step_sfx.autoplay = false
		step_sfx.volume_db = -6.0
		step_sfx.pitch_scale = randf_range(0.98, 1.02)
		Enemy2.add_child(step_sfx)

		# If it's a WAV stream, enable looping
		if STEP_STREAM is AudioStreamWAV:
			var s := STEP_STREAM as AudioStreamWAV
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Save reference on the enemy so Hurt/Death can stop it
	Enemy2.set_meta("step_sfx", step_sfx)

	# Start walking loop
	if STEP_STREAM and not step_sfx.playing:
		step_sfx.play()

func physics_update(Enemy2, delta):
	if not Enemy2.player:
		if step_sfx and step_sfx.playing:
			step_sfx.stop()
		return

	Enemy2.dir = (Enemy2.player.position - Enemy2.position).normalized()
	Enemy2.velocity.x = Enemy2.dir.x * Enemy2.speed

	# If close enough to attack, stop loop then change state
	if Enemy2.position.distance_to(Enemy2.player.position) < Enemy2.attack_range:
		if step_sfx and step_sfx.playing:
			step_sfx.stop()
		Enemy2.change_state(EnemyAttackState2.new())
