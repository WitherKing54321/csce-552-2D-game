extends EnemyState2
class_name EnemyDeathState2

var timer = 1.0

var DEATH_STREAM: AudioStream = preload("res://Sounds/NuckDeath.wav")
var death_sfx: AudioStreamPlayer2D

func enter(Enemy2):
	print("enter Bob deathstate")

	# Stop all movement
	Enemy2.velocity = Vector2.ZERO

	# Stop any audio still playing (like run loops)
	for child in Enemy2.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	# Play death animation
	Enemy2.anim.play("nuckDeath")

	# Play death sound
	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.stream = DEATH_STREAM
		Enemy2.add_child(death_sfx)
	death_sfx.play()

func physics_update(Enemy2, delta):
	timer -= delta
	Enemy2.velocity = Vector2.ZERO
	if timer <= 0.0:
		Enemy2.queue_free()
