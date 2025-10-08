extends EnemyState2
class_name EnemyChaseState2

var STEP2_STREAM: AudioStream = preload("res://Sounds/ZweihanderChase.wav")
var step2_sfx: AudioStreamPlayer2D

func enter(Enemy2):
	Enemy2.anim.play("enemy2Chase")
	print("Entered Chase State")

	if step2_sfx == null:
		step2_sfx = AudioStreamPlayer2D.new()
		step2_sfx.stream = STEP2_STREAM
		step2_sfx.autoplay = false
		step2_sfx.volume_db = 2.0
		step2_sfx.pitch_scale = randf_range(0.98, 1.02)
		Enemy2.add_child(step2_sfx)

		if STEP2_STREAM is AudioStreamWAV:
			var s := STEP2_STREAM as AudioStreamWAV
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD

	Enemy2.set_meta("step2_sfx", step2_sfx)

	if STEP2_STREAM and not step2_sfx.playing:
		step2_sfx.play()

func physics_update(Enemy2, delta):
	if not Enemy2.player:
		return

	Enemy2.dir = (Enemy2.player.position - Enemy2.position).normalized()
	Enemy2.velocity.x = Enemy2.dir.x * Enemy2.speed

	if Enemy2.position.distance_to(Enemy2.player.position) < Enemy2.attack_range:
		if step2_sfx and step2_sfx.playing:
			step2_sfx.stop()
		Enemy2.change_state(EnemyAttackState2.new())
