extends Node

@export var pause_menu_path: NodePath
@onready var pause_menu: Control = get_node(pause_menu_path)
@onready var resume_btn: Button = pause_menu.get_node("VBoxContainer/Resume")
@onready var main_menu_btn: Button = pause_menu.get_node("VBoxContainer/Restart") # ← Main Menu button
@onready var quit_btn: Button = pause_menu.get_node("VBoxContainer/Quit")

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

var is_paused := false

# --- sounds ---
var SCROLL_STREAM: AudioStream = preload("res://Sounds/Menu-Scroll.wav")
@export var scroll_volume_db: float = -6.0  # volume in decibels (0 = full volume)

var scroll_sfx: AudioStreamPlayer


func _ready() -> void:
	# Hide the menu on start
	pause_menu.visible = false

	# Wire button clicks
	resume_btn.pressed.connect(_on_resume_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	# Audio player for scroll sfx
	scroll_sfx = AudioStreamPlayer.new()
	scroll_sfx.stream = SCROLL_STREAM
	scroll_sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll_sfx.volume_db = scroll_volume_db   # ← apply dB volume here
	pause_menu.add_child(scroll_sfx)

	# Play scroll on focus move
	for b in [resume_btn, main_menu_btn, quit_btn]:
		b.focus_entered.connect(_on_button_focus_entered)

	# Let Game autoload reposition the player if a checkpoint exists
	Game.on_scene_ready(self)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		toggle_pause()


func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	if is_paused:
		resume_btn.grab_focus()


func _on_button_focus_entered() -> void:
	if scroll_sfx:
		scroll_sfx.stop()
		scroll_sfx.play()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	pause_menu.hide()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	pause_menu.hide()

	# wipe any saved checkpoint
	if Engine.has_singleton("Game"):
		Game.clear_checkpoint()

	var err := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if err != OK:
		push_error("Failed to load main menu: %s (code %s)" % [MAIN_MENU_SCENE, str(err)])


func _on_quit_pressed() -> void:
	get_tree().quit(0)
