extends PlayerState
class_name RunState

var RUN_SOUND: AudioStream = preload("res://Sounds/8-bit-RunSoundBase.wav")
var run_sfx: AudioStreamPlayer

func enter(player):
	player.anim.play("run")

	# Reuse a single SFX node instead of creating a new one every time
	if player.has_node("RunSFX"):
		run_sfx = player.get_node("RunSFX") as AudioStreamPlayer
	else:
		run_sfx = AudioStreamPlayer.new()
		run_sfx.name = "RunSFX"
		run_sfx.stream = RUN_SOUND
		player.add_child(run_sfx)

	# Only start if it's not already playing
	if not run_sfx.playing:
		run_sfx.play()

func physics_update(player, delta):
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED

	if dir == 0:
		# stop but DON'T free; we want to reuse it later (prevents duplicates)
		if is_instance_valid(run_sfx) and run_sfx.playing:
			run_sfx.stop()
		player.change_state(IdleState.new())
	elif Input.is_action_just_pressed("move_jump") and player.is_on_floor():
		if is_instance_valid(run_sfx) and run_sfx.playing:
			run_sfx.stop()
		player.change_state(JumpState.new())

# (optional, if your FSM calls exit on state change)
func exit(player):
	if is_instance_valid(run_sfx) and run_sfx.playing:
		run_sfx.stop()
