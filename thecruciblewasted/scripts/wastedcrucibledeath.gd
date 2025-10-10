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

func physics_update(Blob, delta):
	timer -= delta
	Blob.velocity = Vector2.ZERO
	if timer <= 0.0:
		Blob.queue_free()
