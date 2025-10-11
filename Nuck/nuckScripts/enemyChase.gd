extends EnemyState
class_name EnemyChaseState

# Tweakable falloff
@export var hear_max_distance: float = 250.0  # px, silent beyond this
@export var hear_falloff: float = 0.4         # higher = fades faster

var STEP_STREAM: AudioStream = preload("res://Sounds/NuckRun.wav")
var step_sfx: AudioStreamPlayer2D

func enter(Enemy):
	Enemy.anim.play("nuckWalk")
	print("Entered Chase State")

	if step_sfx == null:
		step_sfx = AudioStreamPlayer2D.new()
		step_sfx.stream = STEP_STREAM
		step_sfx.autoplay = false
		step_sfx.volume_db = -6.0
		step_sfx.pitch_scale = randf_range(0.98, 1.02)

		# ↓↓↓ Distance controls
		step_sfx.attenuation = hear_falloff
		step_sfx.max_distance = hear_max_distance

		Enemy.add_child(step_sfx)

		if STEP_STREAM is AudioStreamWAV:
			var s := STEP_STREAM as AudioStreamWAV
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Keep values in sync even if player already existed
	step_sfx.attenuation = hear_falloff
	step_sfx.max_distance = hear_max_distance

	Enemy.set_meta("step_sfx", step_sfx)

	if STEP_STREAM and not step_sfx.playing:
		step_sfx.play()

func physics_update(Enemy, delta):
	if not Enemy.player:
		if step_sfx and step_sfx.playing:
			step_sfx.stop()
		return

	Enemy.dir = (Enemy.player.position - Enemy.position).normalized()
	Enemy.velocity.x = Enemy.dir.x * Enemy.speed

	if Enemy.position.distance_to(Enemy.player.position) < Enemy.attack_range:
		if step_sfx and step_sfx.playing:
			step_sfx.stop()
		Enemy.change_state(EnemyAttackState.new())
