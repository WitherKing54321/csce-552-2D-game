# res://scenes/game_success.gd
extends Control

# Node paths (rename in the editor only if yours differ)
@onready var quit_btn: Button = %Quit            # Button node named "Quit"
@onready var root_panel: Control = self          # Root Control for visibility (optional)

func _ready() -> void:
	# Ensure we're not paused on the success screen
	get_tree().paused = false

	# Show the mouse cursor and focus the Quit button for keyboard users
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)
		quit_btn.grab_focus()

	# If this scene is instantiated while hidden, make it visible
	root_panel.visible = true

func _unhandled_input(event: InputEvent) -> void:
	# Enter/Space (ui_accept) or Esc (ui_cancel) should also quit
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()

func _on_quit_pressed() -> void:
	# Match your Game Over menu: exit immediately
	get_tree().quit()
