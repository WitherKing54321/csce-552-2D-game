extends Area2D

@export var player_group: String = "player"
@export var activate_duration: float = 1.3        # seconds for "Activate" animation
@export var spawn_offset: Vector2 = Vector2(0, -8) # where the player should be placed on respawn (relative to shrine)
@export var reactivatable: bool = false            # set true if you want to allow re-activating

var anim: AnimatedSprite2D
var prompt_label: Label
var can_interact := false
var activated := false
var in_activation := false
var activate_timer := 0.0

func _ready() -> void:
	anim = $AnimatedSprite2D
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("Idle"):
		anim.play("Idle")
	prompt_label = $InteractionPrompt
	if prompt_label:
		prompt_label.visible = false

	# Connect Area2D signals (if not connected via editor)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	# Interact to activate
	if can_interact and (reactivatable or not activated):
		if Input.is_action_just_pressed("ui_accept"):
			start_activation()

	# Run the activation timer once started
	if in_activation:
		activate_timer -= delta
		if activate_timer <= 0.0:
			in_activation = false
			if anim and anim.sprite_frames and anim.sprite_frames.has_animation("ActivateIdle"):
				anim.play("ActivateIdle")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group):
		can_interact = true
		if reactivatable or not activated:
			show_prompt("Press [ENTER] to activate")
		else:
			show_prompt("Checkpoint active")

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

func start_activation() -> void:
	# Prevent double-triggering during animation window
	if in_activation:
		return
	in_activation = true
	activate_timer = activate_duration

	# Visuals
	hide_prompt()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("Activate"):
		anim.play("Activate")

	# ✅ Save the checkpoint (scene path + precise world position)
	Game.set_checkpoint(
		get_tree().current_scene.scene_file_path,
		global_position + spawn_offset
	)

	activated = true
	# Optional confirmation after activation
	await get_tree().process_frame
	show_prompt("Checkpoint saved")
