# BlobDeathState.gd
extends BlobState
class_name BlobDeathState

@export var death_delay := 1.0
var enemy_moved := false

func enter(Blob):
	Game.mark_enemy_defeated(Blob.get_tree().current_scene.scene_file_path, Blob.enemy_id)
	Blob.velocity = Vector2.ZERO

	for child in Blob.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			if child.playing:
				child.stop()

	var death_sfx = Blob.get_node_or_null("DeathSfx")
	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.name = "DeathSfx"
		death_sfx.stream = preload("res://Sounds/CrucibleWastedDeath.wav")
		Blob.add_child(death_sfx)
	else:
		if death_sfx.playing:
			death_sfx.stop()
	death_sfx.play()

	if Blob.anim:
		Blob.anim.play("death")

	var t: SceneTreeTimer = Blob.get_tree().create_timer(death_delay)
	t.timeout.connect(func():
		Blob.play_cutscene()
	)

func physics_update(Blob, delta):
	Blob.velocity = Vector2.ZERO

	if Blob.cutsceneover and not enemy_moved:
		enemy_moved = true
		var crucible = Blob.get_node("../TheCrucible")
		if crucible:
			crucible.global_position = Vector2(-6500, 1000)
			crucible.visible = true
			crucible.set_process(true)
			crucible.set_physics_process(true)

			# unmute crucible now
			crucible.set_meta("crucible_muted", false)
			for n in crucible.get_children():
				if n is AudioStreamPlayer or n is AudioStreamPlayer2D:
					if not n.has_meta("orig_vol"):
						n.set_meta("orig_vol", n.volume_db)
					n.volume_db = n.get_meta("orig_vol")

	if Blob.inputcounter == 8:
		var ds = Blob.get_node_or_null("DeathSfx")
		if ds and ds.playing:
			ds.stop()
		Blob.queue_free()
