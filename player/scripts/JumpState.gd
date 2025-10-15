extends PlayerState
class_name JumpState

# Preload once (check the exact paths/case)
var JUMP_SOUND: AudioStream = preload("res://Sounds/8-bit-jump.wav")
var DOUBLEJUMP_SOUND: AudioStream = preload("res://Sounds/8-bit-doublejump.wav")

func _play_sound(player, stream: AudioStream) -> void:
	var sfx := AudioStreamPlayer.new()   # use AudioStreamPlayer2D if you want positional audio
	sfx.stream = stream
	player.add_child(sfx)
	sfx.finished.connect(func(): sfx.queue_free())
	sfx.volume_db = 0.0
	sfx.play()

func enter(player):
	# Handle jump
	if not player.has_double_jumped:
		player.velocity.y = player.JUMP_VELOCITY
		player.anim.play("jump")
		_play_sound(player, JUMP_SOUND)
		# don't force has_double_jumped = false here; it should be reset on landing
	else:
		player.velocity.y = player.DOUBLE_JUMP_VELOCITY
		# player.anim.play("double_jump")
		player.has_double_jumped = true

		
func physics_update(player, delta):
	# Horizontal movement
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED

	# Glide functionality
	if player.velocity.y > 0 and Input.is_action_pressed("glide"):
		player.change_state(GlideState.new())
		return
	if player.velocity.y > 0 and not Input.is_action_just_pressed("glide"):
		player.anim.play("fall")
		
	# Double jump input
	if Input.is_action_just_pressed("move_jump") and not player.has_double_jumped:
		player.velocity.y = player.DOUBLE_JUMP_VELOCITY
		player.anim.play("double_jump")
		_play_sound(player, DOUBLEJUMP_SOUND)
		player.has_double_jumped = true

	# Landed
	elif player.is_on_floor():
		player.has_double_jumped = false  # reset on landing
		player.change_state(IdleState.new())
	
