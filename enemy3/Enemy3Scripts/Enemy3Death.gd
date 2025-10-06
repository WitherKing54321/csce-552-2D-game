extends EnemyState3
class_name EnemyDeathState3

var timer = 2.0
var knockback_timer = 0.3   # time in seconds to let knockback happen
const KNOCKBACK_X := 50   # bigger for visible effect (adjust as needed)
const KNOCKBACK_Y := -60
var DEATH_STREAM: AudioStream = preload("res://Sounds/NuckDeath.wav")
var death_sfx: AudioStreamPlayer2D

func enter(Enemy3):
	var direction = -1 if Enemy3.anim.flip_h else 1
	Enemy3.velocity.x = KNOCKBACK_X * direction
	Enemy3.velocity.y = KNOCKBACK_Y

	# Stop looping sounds
	for child in Enemy3.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	Enemy3.anim.play("death")

	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.stream = DEATH_STREAM
		Enemy3.add_child(death_sfx)
	death_sfx.play()


func physics_update(Enemy3, delta):
	Enemy3.move_and_slide()
	if knockback_timer > 0:
		knockback_timer -= delta
	else:
		Enemy3.velocity = Vector2.ZERO   # freeze after knockback

	timer -= delta
	if timer <= 0.0:
		Enemy3.queue_free()
