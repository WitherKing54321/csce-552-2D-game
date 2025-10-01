extends Node2D

# Lines of dialog (Space to advance)
@export var lines: Array[String] = [
	"Hello from the Butler!",
	"Press Space to see the next line.",
	"When you finish, the box will hide."
]

# Optional: set this on the Butler (or leave empty if the TextureRect already has a texture)
@export var portrait_texture: Texture2D

@onready var zone: Area2D = $TalkZone

# ABSOLUTE paths — change names if your scene differs
@onready var dialog_panel: CanvasItem   = $"/root/Main/DialogUI/DialogPanel"
@onready var dialog_text: RichTextLabel = $"/root/Main/DialogUI/DialogPanel/Text"
@onready var dialog_face: TextureRect   = $"/root/Main/DialogUI/DialogPanel/TextureRect"

var _in_range := false
var _line_idx := -1   # -1 = not showing
var anim: AnimatedSprite2D


func _ready() -> void:
	anim = $AnimatedSprite2D
	$AnimatedSprite2D.flip_h = true
	anim.play("idle")
	# Connect once
	if zone and not zone.body_entered.is_connected(_on_zone_body_entered):
		zone.body_entered.connect(_on_zone_body_entered)
	if zone and not zone.body_exited.is_connected(_on_zone_body_exited):
		zone.body_exited.connect(_on_zone_body_exited)

	# Neutralize any accidental tints/materials so the portrait won't render black
	_neutralize_ui()

	# Hide on start
	_set_visible(false)

func _process(_dt: float) -> void:
	if _in_range and Input.is_action_just_pressed("ui_accept"):
		_on_advance_requested()

func _on_zone_body_entered(body: Node) -> void:
	if not body.is_in_group("player"): return
	_in_range = true
	_start_dialog()

func _on_zone_body_exited(body: Node) -> void:
	if not body.is_in_group("player"): return
	_in_range = false
	_end_dialog()

func _start_dialog() -> void:
	_line_idx = 0
	_apply_portrait()
	_update_text()
	_set_visible(true)

func _end_dialog() -> void:
	_set_visible(false)
	_line_idx = -1

func _on_advance_requested() -> void:
	# If hidden but in range, start fresh
	if dialog_panel and not dialog_panel.visible:
		_start_dialog()
		return

	if _line_idx >= 0 and _line_idx < lines.size() - 1:
		_line_idx += 1
		_update_text()
	else:
		_end_dialog()

func _update_text() -> void:
	if dialog_text and _line_idx >= 0 and _line_idx < lines.size():
		dialog_text.text = lines[_line_idx]

func _apply_portrait() -> void:
	if not dialog_face: return
	# Force sane draw state every time we show dialog
	dialog_face.modulate = Color(1,1,1,1)
	dialog_face.self_modulate = Color(1,1,1,1)
	if "material" in dialog_face: dialog_face.material = null
	dialog_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if portrait_texture:
		dialog_face.texture = portrait_texture

	# Also make sure the panel can't tint children accidentally
	if dialog_panel:
		dialog_panel.modulate = Color(1,1,1,1)
		dialog_panel.self_modulate = Color(1,1,1,1)
		if "material" in dialog_panel: dialog_panel.material = null

func _neutralize_ui() -> void:
	if dialog_face:
		dialog_face.modulate = Color(1,1,1,1)
		dialog_face.self_modulate = Color(1,1,1,1)
		if "material" in dialog_face: dialog_face.material = null
	if dialog_panel:
		dialog_panel.modulate = Color(1,1,1,1)
		dialog_panel.self_modulate = Color(1,1,1,1)
		if "material" in dialog_panel: dialog_panel.material = null

func _set_visible(v: bool) -> void:
	if dialog_panel: dialog_panel.visible = v
	if dialog_text:  dialog_text.visible  = v
	if dialog_face:  dialog_face.visible  = v  # portrait shows whenever the box shows
