extends EnemyState2
class_name EnemyDeathState2

var timer = 2.0
var knockback_timer = 0.3   # time in seconds to let knockback happen
const KNOCKBACK_X := 50   # bigger for visible effect (adjust as needed)
const KNOCKBACK_Y := -60
var DEATH2_STREAM: AudioStream = preload("res://Sounds/ZweihanderDeath.wav")
var death2_sfx: AudioStreamPlayer2D

func enter(Enemy2):
	var direction = -1 if Enemy2.anim.flip_h else 1
	Enemy2.velocity.x = KNOCKBACK_X * direction
	Enemy2.velocity.y = KNOCKBACK_Y

	# Stop looping sounds
	for child in Enemy2.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	Enemy2.anim.play("enemy2Death")

	if death2_sfx == null:
		death2_sfx = AudioStreamPlayer2D.new()
		death2_sfx.stream = DEATH2_STREAM
		Enemy2.add_child(death2_sfx)
	death2_sfx.play()


func physics_update(Enemy2, delta):
	Enemy2.move_and_slide()
	if knockback_timer > 0:
		knockback_timer -= delta
	else:
		Enemy2.velocity = Vector2.ZERO   # freeze after knockback

	timer -= delta
	if timer <= 0.0:
		Enemy2.queue_free()
