extends Control

# Right-click your gameplay scene in FileSystem → Copy Path → paste below:
const GAME_SCENE_PATH := "res://scenes/Main.tscn"  # ← set this to YOUR real game scene

@onready var start_btn: Button = $"VBoxContainer/Start"

func _ready() -> void:
	get_tree().paused = false
	if not start_btn.pressed.is_connected(_on_start_pressed):
		start_btn.pressed.connect(_on_start_pressed)
	start_btn.grab_focus()

func _on_start_pressed() -> void:
	print("START pressed")
	var err := get_tree().change_scene_to_file(GAME_SCENE_PATH)
	print("change_scene err =", err)  # 0 = OK
	if err != OK:
		push_error("Bad scene path or failed to load: " + GAME_SCENE_PATH)
