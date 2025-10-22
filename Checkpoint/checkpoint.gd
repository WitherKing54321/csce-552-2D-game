extends Area2D

@export var player_group: String = "player"
@export var activate_duration: float = 1.3
@export var spawn_offset: Vector2 = Vector2(0, -8)
@export var respawn_position: Vector2 = Vector2.ZERO
@export var reactivatable: bool = false

var can_interact := false
var activated := false
var in_activation := false
var activate_timer := 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $InteractionPrompt

func _ready() -> void:
	# Ensure bindings exist even if the export missed Project Settings → Input Map
	_ensure_interact_binding()

	# Initial visuals
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("Idle"):
		anim.play("Idle")
	if prompt_label:
		prompt_label.visible = false

	can_interact = false
	activated = false
	in_activation = false

	# Robust signal connections (Godot 4 style)
	var entered_cb := Callable(self, "_on_body_entered")
	var exited_cb := Callable(self, "_on_body_exited")
	if not self.body_entered.is_connected(entered_cb):
		self.body_entered.connect(entered_cb)
	if not self.body_exited.is_connected(exited_cb):
		self.body_exited.connect(exited_cb)

	# If the game can be paused near a checkpoint and you still want it to work:
	# process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	# Handle gameplay input AFTER UI so hidden/focused Controls can’t swallow keys
	if not can_interact:
		return
	if activated and not reactivatable:
		return

	var pressed := false
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		pressed = true
	elif event is InputEventKey and event.pressed:
		# Accept both Enter keys explicitly
		if event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER:
			pressed = true

	if pressed:
		start_activation()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
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
			show_prompt("Press [E] or [ENTER] to activate")
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
	if in_activation:
		return
	in_activation = true
	activate_timer = activate_duration

	# SFX (one-shot)
	var sfx := get_node_or_null("ActivateSfx") as AudioStreamPlayer2D
	if sfx == null:
		sfx = AudioStreamPlayer2D.new()
		sfx.name = "ActivateSfx"
		sfx.stream = preload("res://Sounds/CheckPoint.wav") # ← adjust path if needed
		add_child(sfx)
	else:
		if sfx.playing:
			sfx.stop()
	sfx.play()

	# Visuals
	hide_prompt()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("Activate"):
		anim.play("Activate")

	# Compute respawn
	var final_respawn := respawn_position
	if final_respawn == Vector2.ZERO:
		final_respawn = global_position + spawn_offset

	# Save via autoload if present
	var game := get_node_or_null("/root/Game")
	if game:
		game.set_checkpoint(get_tree().current_scene.scene_file_path, final_respawn)
	else:
		push_error("Checkpoint: /root/Game autoload not found (Project Settings → Autoload).")

	activated = true
	await get_tree().process_frame
	show_prompt("Checkpoint saved")

# -------- helpers --------

func _ensure_interact_binding() -> void:
	# Create action if missing
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")

	# Track existing keys
	var have_e := false
	var have_enter := false
	var have_kp_enter := false
	for ev in InputMap.action_get_events("interact"):
		if ev is InputEventKey:
			match ev.physical_keycode:
				KEY_E: have_e = true
				KEY_ENTER: have_enter = true
				KEY_KP_ENTER: have_kp_enter = true

	# Add keys if missing
	if not have_e:
		var e := InputEventKey.new()
		e.physical_keycode = KEY_E
		InputMap.action_add_event("interact", e)

	if not have_enter:
		var enter := InputEventKey.new()
		enter.physical_keycode = KEY_ENTER
		InputMap.action_add_event("interact", enter)

	if not have_kp_enter:
		var kp := InputEventKey.new()
		kp.physical_keycode = KEY_KP_ENTER
		InputMap.action_add_event("interact", kp)
