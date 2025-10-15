extends CharacterBody2D
class_name Blob  # all instances of Crucible Wasted are 'blob'

@export var speed := 25
@export var attack_range := 20
@export var chase_range := 50
@export var gravity := 800
var health := 100
var player: Node = null
var anim: AnimatedSprite2D
var state: BlobState = null
var attack := false
var directionFacingRight := true
var dir := Vector2.ZERO
var invincible_timer := 0.0

# --- Dialogue Variables ---
@export var _dialogue_lines: Array[String] = []
@export var portrait_texture: Texture2D

@onready var dialog_panel: CanvasItem   = $"/root/Main/UIGroup/DialogUI/DialogPanel"
@onready var dialog_text: RichTextLabel = $"/root/Main/UIGroup/DialogUI/DialogPanel/Text"
@onready var dialog_face: TextureRect   = $"/root/Main/UIGroup/DialogUI/DialogPanel/MiaPortrait"
@onready var cutscene_overlay: TextureRect = $"/root/Main/UIGroup/HealthUI/TextureRect"
@onready var cutscene_anim: AnimatedSprite2D = $"/root/Main/UIGroup/HealthUI/TextureRect/AnimatedSprite2D"

@export var enemy_id := "crucible_wasted_boss"

var _line_idx := -1
var _dialog_active := false
var inputcounter = 0
var cutsceneover := false

# -------------------------------------------------------
# NORMAL BLOB STUFF
# -------------------------------------------------------

func _ready():
	
	if Game.is_enemy_defeated(get_tree().current_scene.scene_file_path, enemy_id):
		var next_enemy = get_node("../TheCrucible")
		if next_enemy:
			print("move enemy")
			next_enemy.global_position = Vector2(-6500, 1000)
			next_enemy.visible = true
			next_enemy.set_process(true)
			next_enemy.set_physics_process(true)
		queue_free()  # Don’t spawn a dead enemy again

	cutscene_overlay.visible = false
	player = get_tree().get_first_node_in_group("player")
	anim = $AnimatedSprite2D
	change_state(BlobIdleState.new())

	var hurtbox = get_node("hurtbox")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _on_hurtbox_area_entered(area: Node):
	if area.is_in_group("player_sword") and invincible_timer <= 0:
		take_damage(10)

func take_damage(amount: int):
	health -= amount
	invincible_timer = 0.3  # short invulnerability period

	var hurt_state = BlobHurtState.new()
	hurt_state.damage_taken = amount
	change_state(hurt_state)

	if health <= 0:
		change_state(BlobDeathState.new())

func _physics_process(delta):
	invincible_timer -= delta
	if state:
		state.physics_update(self, delta)

	velocity.y += gravity * delta
	move_and_slide()

	# Update facing direction
	if velocity.x < 0:
		directionFacingRight = true
	elif velocity.x > 0:
		directionFacingRight = false

	anim.flip_h = not directionFacingRight

func change_state(new_state: BlobState):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)

# -------------------------------------------------------
# DIALOGUE SYSTEM (local, callable from anywhere)
# -------------------------------------------------------

func show_dialogue(lines: Array[String], portrait_rect: TextureRect):
	for child in dialog_panel.get_children():
		if child is TextureRect:
			child.visible = false

	if portrait_rect:
		portrait_rect.visible = true

	dialog_panel.visible = true
	dialog_text.visible = true

	_dialog_active = true
	_line_idx = 0
	_dialogue_lines = lines
	dialog_text.text = _dialogue_lines[_line_idx]

	set_process_input(true)

func _input(event):
	if not _dialog_active:
		return

	if event.is_action_pressed("ui_accept"):
		inputcounter += 1
		_line_idx += 1
		if _line_idx < _dialogue_lines.size():
			dialog_text.text = _dialogue_lines[_line_idx]
		else:
			hide_dialogue()

func hide_dialogue():
	if not _dialog_active:
		return

	dialog_panel.visible = false
	dialog_text.visible = false

	for child in dialog_panel.get_children():
		if child is TextureRect:
			child.visible = false

	_dialog_active = false
	set_process_input(false)
	play_cutscene()

# -------------------------------------------------------
# CUTSCENE FUNCTION
# -------------------------------------------------------

func play_cutscene():
	cutscene_overlay.visible = true
	if inputcounter == 0:
		show_dialogue(
			["Wait..","I know I've been here before"] as Array[String],
			dialog_panel.get_node("MiaPortrait")
		)
		cutscene_anim.play("cutscene00")
	if inputcounter == 2:
		show_dialogue(
			["so we've found it","the ancient primordial fire"] as Array[String],
			dialog_panel.get_node("AlgenonPortrait")
		)
		cutscene_anim.play("cutscene01")
	if inputcounter == 4:
		show_dialogue(
			["and it seems we've found it's guardian"] as Array[String],
			dialog_panel.get_node("RodionPortrait")
		)
		cutscene_anim.play("cutscene02")
	if inputcounter == 5:
		show_dialogue(
			["You can't leave me here!"] as Array[String],
			dialog_panel.get_node("MiaPortrait")
		)
		show_dialogue(
			["Farewell Mia","There is no place for you in the new world we will create."] as Array[String],
			dialog_panel.get_node("AlgenonPortrait")
		)
		cutscene_anim.play("cutscene03")
	if inputcounter == 7:
		print("cutsceneover")
		cutsceneover = true
		cutscene_overlay.visible = false
