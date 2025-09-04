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
	#player.anim.play("bird_appear")
	player.anim.play("glide")
	_play_sound(player, RAVENGLIDE_SOUND)
	
func physics_update(player, delta):
	player.velocity.y = min(player.velocity.y, 50) # cap fall speed

	if not Input.is_action_pressed("glide") or player.is_on_floor():
		if is_instance_valid(raven_sfx):
			raven_sfx.stop()
			raven_sfx.queue_free()
		player.anim.play("bird_disappear")
		player.change_state(IdleState.new())
