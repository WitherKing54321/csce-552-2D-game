extends BossState
class_name BossDeathState

var timer := 2.3
var DEATH_STREAM: AudioStream = preload("res://Sounds/ZweihanderDeath.wav")
var death_sfx: AudioStreamPlayer2D

func enter(Boss):
	print("Boss begins death sequence")

	# Stop all sounds that may still be playing
	for child in Boss.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	# Play death animation
	if Boss.sprite:
		Boss.sprite.play("death")

	# Play death sound
	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.stream = DEATH_STREAM
		Boss.add_child(death_sfx)
	death_sfx.play()

	# Ensure boss stays completely still
	Boss.velocity = Vector2.ZERO


func physics_update(Boss, delta):
	Boss.velocity = Vector2.ZERO
	timer -= delta

func exit(Boss):
	# No cleanup necessary, but keep consistent behavior
	Boss.velocity = Vector2.ZERO
