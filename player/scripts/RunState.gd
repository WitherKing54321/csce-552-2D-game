extends PlayerState
class_name RunState

var RUN_SOUND: AudioStream = preload("res://Sounds/RunSoundBase.wav")
var run_sfx: AudioStreamPlayer

func enter(player):
	player.anim.play("run")

	# start running sound
	run_sfx = AudioStreamPlayer.new()
	run_sfx.stream = RUN_SOUND
	player.add_child(run_sfx)
	run_sfx.play()

func physics_update(player, delta):
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED

	if dir == 0:
		if is_instance_valid(run_sfx):
			run_sfx.stop()
			run_sfx.queue_free()
		player.change_state(IdleState.new())
	elif Input.is_action_just_pressed("move_jump") and player.is_on_floor():
		if is_instance_valid(run_sfx):
			run_sfx.stop()
			run_sfx.queue_free()
		player.change_state(JumpState.new())
