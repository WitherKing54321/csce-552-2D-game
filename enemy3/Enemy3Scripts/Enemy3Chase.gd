extends EnemyState3
class_name EnemyChaseState3

# --- AUDIO: preload a loop (footsteps/armor clank) ---
var STEP3_STREAM: AudioStream = preload("res://Sounds/CloakChase.wav")
var step3_sfx: AudioStreamPlayer2D

func enter(Enemy3):
	Enemy3.anim.play("chase")
	print("Entered Chase State")

	# Create the audio player once and reuse it
	if step3_sfx == null:
		step3_sfx = AudioStreamPlayer2D.new()
		step3_sfx.stream = STEP3_STREAM
		step3_sfx.autoplay = false
		step3_sfx.volume_db = -4.0
		step3_sfx.pitch_scale = randf_range(0.98, 1.02)
		Enemy3.add_child(step3_sfx)

		# If it's a WAV stream, enable looping
		if STEP3_STREAM is AudioStreamWAV:
			var s := STEP3_STREAM as AudioStreamWAV
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Save reference on the enemy so Hurt/Death can stop it
	Enemy3.set_meta("step3_sfx", step3_sfx)

	# Start walking loop
	if STEP3_STREAM and not step3_sfx.playing:
		step3_sfx.play()

func physics_update(Enemy3, delta):
	if not Enemy3.player:
		return

	Enemy3.dir = (Enemy3.player.position - Enemy3.position).normalized()
	Enemy3.velocity.x = Enemy3.dir.x * Enemy3.speed

	# If close enough to attack, stop loop then change state
	if Enemy3.position.distance_to(Enemy3.player.position) < Enemy3.attack_range:
		if step3_sfx and step3_sfx.playing:
			step3_sfx.stop()
		Enemy3.change_state(EnemyAttackState3.new())
