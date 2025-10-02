extends CanvasLayer

@onready var _root: Control      = $Control
@onready var _retry_btn: Button  = $"Control/Panel/VBoxContainer/Retry"
@onready var _start_btn: Button  = $"Control/Panel/VBoxContainer/StartOver"
@onready var _menu_btn: Button   = $"Control/Panel/VBoxContainer/MainMenu"
@onready var _quit_btn: Button   = $"Control/Panel/VBoxContainer/Quit"

@export var title_scene_path := "res://scenes/Title.tscn"

func _ready() -> void:
	# Must be visible=false at start; we fade in when shown
	_root.visible = false
	_root.modulate.a = 0.0

	# Wire buttons
	_retry_btn.pressed.connect(_on_retry)
	_start_btn.pressed.connect(_on_start_over)
	_menu_btn.pressed.connect(_on_main_menu)
	_quit_btn.pressed.connect(_on_quit)

	# Ensure the layer runs while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[GameOverLayer] ready (process_mode=ALWAYS)")

func show_game_over() -> void:
	print("[GameOverLayer] show_game_over()")
	_root.visible = true

	# Pause the game via autoload
	if Engine.has_singleton("Game"):
		Game._pause()
	else:
		# fallback if autoload name differs, try via /root
		var g := get_node_or_null("/root/Game")
		if g: g.call("_pause")

	# Fade in
	var tw := create_tween()
	tw.tween_property(_root, "modulate:a", 1.0, 0.25)
	await get_tree().process_frame
	_retry_btn.grab_focus()

func _hide_and_unpause() -> void:
	_root.visible = false
	_root.modulate.a = 0.0
	# Unpause
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
	if Engine.has_singleton("Game"):
		Game.reload_current_scene()
	else:
		var g := get_node_or_null("/root/Game")
		if g: g.call("reload_current_scene")

func _on_main_menu() -> void:
	print("[GameOverLayer] Returning to Main Menu…")
	_hide_and_unpause()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_quit() -> void:
	get_tree().quit()

func _unhandled_input(e: InputEvent) -> void:
	if _root.visible and e.is_action_pressed("ui_cancel"):
		_on_retry()
