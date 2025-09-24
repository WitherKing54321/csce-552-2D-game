extends Control

# Right-click your gameplay scene in FileSystem → Copy Path → paste below:
const GAME_SCENE_PATH := "res://scenes/Main.tscn"  # ← set this to YOUR real game scene

@onready var start_btn: Button = $"VBoxContainer/Start"

# --- preload and setup select sound ---
var SELECT_STREAM: AudioStream = preload("res://Sounds/Menu-Select.wav")
var select_sfx: AudioStreamPlayer

# --- exported volume for inspector ---
@export var select_volume_db: float = -6.0   # 0 = normal, negative = quieter, positive = louder

func _ready() -> void:
	get_tree().paused = false

	# setup audio player
	select_sfx = AudioStreamPlayer.new()
	select_sfx.stream = SELECT_STREAM
	select_sfx.volume_db = select_volume_db   # apply exported value
	add_child(select_sfx)

	if not start_btn.pressed.is_connected(_on_start_pressed):
		start_btn.pressed.connect(_on_start_pressed)
	start_btn.grab_focus()

func _on_start_pressed() -> void:
	print("START pressed")

	# play select sound
	select_sfx.play()

	# change to game scene
	var err := get_tree().change_scene_to_file(GAME_SCENE_PATH)
	print("change_scene err =", err)  # 0 = OK
	if err != OK:
		push_error("Bad scene path or failed to load: " + GAME_SCENE_PATH)
