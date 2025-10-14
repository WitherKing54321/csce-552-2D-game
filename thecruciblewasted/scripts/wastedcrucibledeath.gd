extends BlobState
class_name BlobDeathState

var timer := 1.0

func enter(Blob):
	print("Enter Blob Death State")

	# Stop all movement
	Blob.velocity = Vector2.ZERO

	# Stop any audio still playing (like run loops)
	for child in Blob.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	# Play death animation
	if Blob.anim:
		Blob.anim.play("death")  # adjust to your Blob death animation

	# Play death sound
	var death_sfx = Blob.get_node_or_null("DeathSfx")
	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.name = "DeathSfx"
		death_sfx.stream = preload("res://Sounds/CrucibleWastedDeath.wav") # set your path
		Blob.add_child(death_sfx)
	else:
		if death_sfx.playing:
			death_sfx.stop()
	death_sfx.play()

func physics_update(Blob, delta):
	timer -= delta
	Blob.velocity = Vector2.ZERO
	if timer <= 0.0:
		# Optional: stop death sfx just before freeing
		var death_sfx = Blob.get_node_or_null("DeathSfx")
		if death_sfx and death_sfx.playing:
			death_sfx.stop()
		Blob.queue_free()
