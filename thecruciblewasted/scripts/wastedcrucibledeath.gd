extends BlobState
class_name BlobDeathState

@export var death_delay := 1.0  # seconds before triggering cutscene and enemy move
var enemy_moved := false  # flag to ensure enemy only moves once

func enter(Blob):
	# Mark this enemy as permanently defeated
	Game.mark_enemy_defeated(Blob.get_tree().current_scene.scene_file_path, Blob.enemy_id)
	
	Blob.velocity = Vector2.ZERO

	# Stop all audio
	for child in Blob.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	# Play death animation
	if Blob.anim:
		Blob.anim.play("death")

	# Start timer using Blob's scene tree to trigger cutscene after delay
	var timer: SceneTreeTimer = Blob.get_tree().create_timer(death_delay)
	timer.timeout.connect(func():
		Blob.play_cutscene()
	)


func physics_update(Blob, delta):
	# Keep Blob frozen during death animation
	Blob.velocity = Vector2.ZERO

	# Once the cutscene finishes, move the next enemy
	if Blob.cutsceneover and not enemy_moved:
		print("the cutscene is over")
		enemy_moved = true
		var next_enemy = Blob.get_node("../TheCrucible")
		if next_enemy:
			print("move enemy")
			next_enemy.global_position = Vector2(-6500, 1000)
			next_enemy.visible = true
			next_enemy.set_process(true)
			next_enemy.set_physics_process(true)
		else:
			print("Warning: Could not find next enemy at path '../TheCrucible'")

	# Queue free the Blob after the last input counter (optional)
	if Blob.inputcounter == 8:
		Blob.queue_free()
