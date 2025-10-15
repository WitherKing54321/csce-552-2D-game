extends Node2D

# Lines of dialogue
@export var lines: Array[String] = [
	"Below is where I found you injured.",#0
	"Perhaps the view will jog your memory.",#0
	"But be careful, a Burning Presence still lurks down there.",
	"...",
	"So be it."
	
]

# Portrait index for each line (0 = face1, 1 = face2, etc.)
@export var line_portraits_idx: Array[int] = [0, 1, 1, 3, 3]

# Nodes
@onready var zone: Area2D = $TalkZone
@onready var dialog_panel: CanvasItem = $"/root/Main/UIGroup/DialogUI/DialogPanel"
@onready var dialog_text: RichTextLabel = $"/root/Main/UIGroup/DialogUI/DialogPanel/Text"
@onready var faces: Array[TextureRect] = [
	$"/root/Main/UIGroup/DialogUI/DialogPanel/ButlerNeutral",
	$"/root/Main/UIGroup/DialogUI/DialogPanel/ButlerLocked",
	$"/root/Main/UIGroup/DialogUI/DialogPanel/ButlerGeeked",
	$"/root/Main/UIGroup/DialogUI/DialogPanel/MiaPortrait"
]

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _in_range := false
var _line_idx := -1  # -1 = not showing

func _ready() -> void:
	anim.flip_h = false
	anim.play("idle")

	# Connect signals
	zone.body_entered.connect(_on_zone_body_entered)
	zone.body_exited.connect(_on_zone_body_exited)

	_set_visible(false)

func _process(_dt: float) -> void:
	if _in_range and Input.is_action_just_pressed("ui_accept"):
		_on_advance_requested()

# ---------------------------
# Zone detection
# ---------------------------

func _on_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = true
		_start_dialog()

func _on_zone_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_in_range = false
		_end_dialog()

# ---------------------------
# Dialogue control
# ---------------------------

func _start_dialog() -> void:
	_line_idx = 0
	_set_visible(true)
	_update_text()
	_apply_portrait()

func _end_dialog() -> void:
	_set_visible(false)
	_line_idx = -1

func _on_advance_requested() -> void:
	if _line_idx < 0:
		_start_dialog()
		return

	if _line_idx < lines.size() - 1:
		_line_idx += 1
		_update_text()
		_apply_portrait()
	else:
		_end_dialog()

# ---------------------------
# UI updates
# ---------------------------

func _update_text() -> void:
	if _line_idx >= 0 and _line_idx < lines.size():
		dialog_text.text = lines[_line_idx]

func _apply_portrait() -> void:
	# Hide all faces
	for face in faces:
		face.visible = false

	# Show the current line's portrait
	if _line_idx >= 0 and _line_idx < line_portraits_idx.size():
		var idx = line_portraits_idx[_line_idx]
		if idx >= 0 and idx < faces.size():
			faces[idx].visible = true

func _set_visible(v: bool) -> void:
	dialog_panel.visible = v
	dialog_text.visible = v
	# Faces will be controlled only by _apply_portrait()
