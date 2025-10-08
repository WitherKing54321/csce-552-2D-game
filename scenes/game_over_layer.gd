extends CanvasLayer

@onready var _root: Control      = $Control
@onready var _retry_btn: Button  = $"Control/Panel/VBoxContainer/Retry"
@onready var _start_btn: Button  = $"Control/Panel/VBoxContainer/StartOver"
@onready var _menu_btn: Button   = $"Control/Panel/VBoxContainer/MainMenu"
@onready var _quit_btn: Button   = $"Control/Panel/VBoxContainer/Quit"

@export var title_scene_path := "res://scenes/Title.tscn"

# --- sounds ---
var SCROLL_STREAM: AudioStream = preload("res://Sounds/Menu-Scroll.wav")
var RESTART_STREAM: AudioStream = preload("res://Sounds/Restart Menu Music.wav")

# --- volume controls (in decibels) ---
@export var scroll_volume_db: float = -3.0   # 0 = full volume, -6 = quieter
@export var restart_volume_db: float = 0.0  # louder popup sound

var scroll_sfx: AudioStreamPlayer
var restart_sfx: AudioStreamPlayer
var _suppress_next_focus_sound := false


func _ready() -> void:
	_root.visible = false
	_root.modulate.a = 0.0

	_retry_btn.pressed.connect(_on_retry)
	_start_btn.pressed.connect(_on_start_over)
	_menu_btn.pressed.connect(_on_main_menu)
	_quit_btn.pressed.connect(_on_quit)

	for b in [_retry_btn, _start_btn, _menu_btn, _quit_btn]:
		b.focus_entered.connect(_on_button_focus)

	# scroll sound
	scroll_sfx = AudioStreamPlayer.new()
	scroll_sfx.stream = SCROLL_STREAM
	scroll_sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll_sfx.volume_db = scroll_volume_db
	add_child(scroll_sfx)

	# popup sound
	restart_sfx = AudioStreamPlayer.new()
	restart_sfx.stream = RESTART_STREAM
	restart_sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_sfx.volume_db = restart_volume_db
	add_child(restart_sfx)

	process_mode = Node.PROCESS_MODE_ALWAYS


func show_game_over() -> void:
	_root.visible = true

	# pause game
	if Engine.has_singleton("Game"):
		Game._pause()
	else:
		var g := get_node_or_null("/root/Game")
		if g: g.call("_pause")

	# play popup sound once
	_play_popup()

	# fade in
	var tw := create_tween()
	tw.tween_property(_root, "modulate:a", 1.0, 0.25)
	await get_tree().process_frame

	_suppress_next_focus_sound = true
	_retry_btn.grab_focus()


func _hide_and_unpause() -> void:
	_root.visible = false
	_root.modulate.a = 0.0
	if Engine.has_singleton("Game"):
		Game._unpause()
	else:
		var g := get_node_or_null("/root/Game")
		if g: g.call("_unpause")


func _on_retry() -> void:
	_hide_and_unpause()
	if Engine.has_singleton("Game"):
		if Game.has_checkpoint:
			Game.respawn_at_checkpoint()
		else:
			Game.reload_current_scene()
	else:
		var g := get_node_or_null("/root/Game")
		if g:
			if g.get("has_checkpoint"):
				g.call("respawn_at_checkpoint")
			else:
				g.call("reload_current_scene")


func _on_start_over() -> void:
	_hide_and_unpause()
	Game.clear_checkpoint()
	get_tree().reload_current_scene()


func _on_main_menu() -> void:
	_hide_and_unpause()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_quit() -> void:
	get_tree().quit()


func _unhandled_input(e: InputEvent) -> void:
	if _root.visible and e.is_action_pressed("ui_cancel"):
		_play_scroll()
		_on_retry()


func _on_button_focus() -> void:
	if _suppress_next_focus_sound:
		_suppress_next_focus_sound = false
		return
	_play_scroll()


func _play_scroll() -> void:
	if scroll_sfx:
		scroll_sfx.stop()
		scroll_sfx.play()


func _play_popup() -> void:
	if restart_sfx:
		restart_sfx.stop()
		restart_sfx.play()
