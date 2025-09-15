extends Node

@export var pause_menu_path: NodePath
@onready var pause_menu: Control = get_node(pause_menu_path)
@onready var resume_btn: Button = pause_menu.get_node("VBoxContainer/Resume")
@onready var restart_btn: Button = pause_menu.get_node("VBoxContainer/Restart")
@onready var quit_btn: Button = pause_menu.get_node("VBoxContainer/Quit")

var is_paused := false

func _ready() -> void:
	# Hide the menu on start
	pause_menu.visible = false
	# Wire button clicks to functions
	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	if is_paused:
		resume_btn.grab_focus()  # gamepad/keyboard friendly

func _on_resume_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	pause_menu.hide()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	# Pick ONE behavior:
	# A) return to a main menu scene:
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	# B) OR quit the game entirely (for desktop builds):
	# get_tree().quit()
