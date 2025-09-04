extends PlayerState
class_name GlideState
var RAVENGLIDE_SOUND: AudioStream = preload("res://Sounds/RavenGlide.wav")
var raven_sfx: AudioStreamPlayer

func _play_sound(player, stream: AudioStream) -> void:
	raven_sfx = AudioStreamPlayer.new()   # use AudioStreamPlayer2D if you want positional audio
	raven_sfx.stream = stream
	player.add_child(raven_sfx)
	raven_sfx.play()
	
func enter(player):
	player.anim.play("glide")
	_play_sound(player, RAVENGLIDE_SOUND)
	
func physics_update(player, delta):
	# Cap vertical velocity
	player.velocity.y = min(player.velocity.y, 50)
	var dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.velocity.x = dir * player.SPEED/1.5

	# Check if glide ends
	if not Input.is_action_pressed("glide") or player.is_on_floor():

		if is_instance_valid(raven_sfx):
			raven_sfx.stop()
			raven_sfx.queue_free()

		player.anim.play("bird_disappear")
		player.change_state(IdleState.new())
