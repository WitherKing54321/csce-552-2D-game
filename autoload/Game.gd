extends Node

# ---- Checkpoint data ----
var has_checkpoint: bool = false
var checkpoint_scene_path: String = ""
var checkpoint_position: Vector2 = Vector2.ZERO

# ---- Enemy state tracking ----
var defeated_enemies := {}  # Dictionary: scene_path -> [enemy_ids]


# ---- Resume gating (only warp when this is true) ----
var resume_from_checkpoint: bool = false

# Save a checkpoint (call from Checkpoint.gd on activate)
func set_checkpoint(scene_path: String, position: Vector2) -> void:
	checkpoint_scene_path = scene_path
	checkpoint_position = position
	has_checkpoint = true
	print("[Game] Checkpoint saved at ", checkpoint_position, " in ", scene_path)

# Clear any saved checkpoint and disable resume
func clear_checkpoint() -> void:
	has_checkpoint = false
	checkpoint_scene_path = ""
	checkpoint_position = Vector2.ZERO
	resume_from_checkpoint = false
	print("[Game] Checkpoint cleared")

# Reload current level; if a checkpoint exists, mark that we should warp after reload
func respawn() -> void:
	if has_checkpoint:
		resume_from_checkpoint = true
	get_tree().reload_current_scene()

# Optional: jump to the checkpoint scene and resume from there
func continue_from_checkpoint() -> void:
	if not has_checkpoint:
		print("[Game] No checkpoint to continue from")
		return
	resume_from_checkpoint = true
	var curr := get_tree().current_scene
	if curr and curr.scene_file_path == checkpoint_scene_path:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file(checkpoint_scene_path)

# Call this from your level root's _ready(): Game.on_scene_ready(self)
func on_scene_ready(root: Node) -> void:
	if not has_checkpoint or not resume_from_checkpoint:
		return
	if root.scene_file_path != checkpoint_scene_path:
		# We landed in a different scene than where the checkpoint was saved—don't warp.
		resume_from_checkpoint = false
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		print("[Game] No node in 'player' group to move to checkpoint.")
		resume_from_checkpoint = false
		return

	var p := players[0]
	if p is Node2D:
		(p as Node2D).global_position = checkpoint_position
		if p.has_method("reset_for_respawn"):
			p.reset_for_respawn()
		print("[Game] Player moved to checkpoint: ", checkpoint_position)
	else:
		print("[Game] Player is not a Node2D; cannot set position.")

	# Consume the resume so a fresh Start won’t warp
	resume_from_checkpoint = false

# --- Pause helpers & compatibility shims (for older UI code) ---
func _pause() -> void: get_tree().paused = true
func _unpause() -> void: get_tree().paused = false
func respawn_at_checkpoint() -> void: respawn()
func reload_current_scene() -> void: get_tree().reload_current_scene()

func mark_enemy_defeated(scene_path: String, enemy_id: String) -> void:
	if not defeated_enemies.has(scene_path):
		defeated_enemies[scene_path] = []
	if enemy_id not in defeated_enemies[scene_path]:
		defeated_enemies[scene_path].append(enemy_id)
	print("[Game] Enemy defeated:", enemy_id, "in", scene_path)

func is_enemy_defeated(scene_path: String, enemy_id: String) -> bool:
	return defeated_enemies.has(scene_path) and enemy_id in defeated_enemies[scene_path]
