extends Node

@export var pause_menu_path: NodePath
@onready var pause_menu: Control = get_node(pause_menu_path)
@onready var resume_btn: Button = pause_menu.get_node("VBoxContainer/Resume")
@onready var restart_btn: Button = pause_menu.get_node("VBoxContainer/Restart")
@onready var quit_btn: Button = pause_menu.get_node("VBoxContainer/Quit")
const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

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
	print("Go to MAIN MENU")
	get_tree().paused = false
	is_paused = false
	pause_menu.hide()
	var err := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if err != OK:
		push_error("Failed to load main menu: " + MAIN_MENU_SCENE + " (code " + str(err) + ")")
	
func _on_quit_pressed() -> void:
	print("QUIT")            # for sanity in the Output panel
	get_tree().quit(0)       # closes the running game/editor play window


func _on_talk_zone_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_talk_zone_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_talk_zone_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
