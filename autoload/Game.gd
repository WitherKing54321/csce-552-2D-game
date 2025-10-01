# res://autoload/Game.gd
extends Node

var last_checkpoint_scene_path: String
var last_checkpoint_transform: Transform2D
var has_checkpoint := false

func set_checkpoint(node: Node2D) -> void:
	if get_tree().current_scene:
		last_checkpoint_scene_path = get_tree().current_scene.scene_file_path
	has_checkpoint = true
	last_checkpoint_transform = node.global_transform

func reload_current_scene() -> void:
	var path := get_tree().current_scene.scene_file_path
	_unpause()
	get_tree().change_scene_to_file(path)

func respawn_at_checkpoint() -> void:
	if not has_checkpoint:
		reload_current_scene()
		return
	_unpause()
	get_tree().change_scene_to_file(last_checkpoint_scene_path)
	await get_tree().process_frame
	var player := get_tree().current_scene.get_node_or_null("%Player")
	if player and player is Node2D:
		player.global_transform = last_checkpoint_transform

func go_to_title(title_scene_path: String) -> void:
	_unpause()
	get_tree().change_scene_to_file(title_scene_path)

func _pause() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unpause() -> void:
	get_tree().paused = false
