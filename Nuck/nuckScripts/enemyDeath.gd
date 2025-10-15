extends EnemyState
class_name EnemyDeathState

var timer = 1.0

var DEATH_STREAM: AudioStream = preload("res://Sounds/NuckDeath.wav")
var death_sfx: AudioStreamPlayer2D

func enter(Enemy):
	print("enter nuck deathstate")

	# Stop all movement
	Enemy.velocity = Vector2.ZERO

	# Stop any audio still playing (like run loops)
	for child in Enemy.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	# Play death animation
	Enemy.anim.play("nuckDeath")

	# Play death sound
	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.stream = DEATH_STREAM
		death_sfx.volume_db = 0.0
		Enemy.add_child(death_sfx)
	death_sfx.play()

func physics_update(Enemy, delta):
	timer -= delta
	Enemy.velocity = Vector2.ZERO
	if timer <= 0.0:
		Enemy.queue_free()
