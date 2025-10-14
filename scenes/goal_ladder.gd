extends Area2D

@export var player_group: String = "player"
@export var success_scene: String = "res://scenes/GameSuccess.tscn" # your end cutscene scene

var prompt_label: Label
var can_interact := false

func _ready() -> void:
	prompt_label = $InteractionPrompt
	if prompt_label:
		prompt_label.visible = false

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("ui_accept"):
		activate_goal()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group):
		can_interact = true
		show_prompt("Press [ENTER] to exit the dungeon")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(player_group):
		can_interact = false
		hide_prompt()

func show_prompt(text: String) -> void:
	if prompt_label:
		prompt_label.text = text
		prompt_label.visible = true

func hide_prompt() -> void:
	if prompt_label:
		prompt_label.visible = false

func activate_goal() -> void:
	can_interact = false
	hide_prompt()
	get_tree().change_scene_to_file(success_scene)
