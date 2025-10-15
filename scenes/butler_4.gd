extends Node2D

@export var lines: Array[String] = [
	"The final challenge lies ahead.",
	"May the gods rest your soul..."
]

@export var portrait_name: String = "ButlerNeutral"

@onready var zone: Area2D = $TalkZone
@onready var dialog_panel: CanvasItem = $"/root/Main/UIGroup/DialogUI/DialogPanel"
@onready var dialog_text: RichTextLabel = dialog_panel.get_node("Text")

var _in_range := false
var _line_idx := -1

func _ready():
	_hide_all_portraits()
	_set_visible(false)
	if zone:
		zone.body_entered.connect(_on_zone_body_entered)
		zone.body_exited.connect(_on_zone_body_exited)

func _process(_dt):
	if _in_range and Input.is_action_just_pressed("ui_accept"):
		_on_advance_requested()

func _on_zone_body_entered(body):
	if body.is_in_group("player"):
		_in_range = true
		_start_dialog()

func _on_zone_body_exited(body):
	if body.is_in_group("player"):
		_in_range = false
		_end_dialog()

func _start_dialog():
	_line_idx = 0
	_set_visible(true)
	_show_portrait(portrait_name)
	_update_text()

func _end_dialog():
	_set_visible(false)
	_hide_all_portraits()
	_line_idx = -1

func _on_advance_requested():
	if dialog_panel and not dialog_panel.visible:
		_start_dialog()
		return
	if _line_idx < lines.size() - 1:
		_line_idx += 1
		_update_text()
	else:
		_end_dialog()

func _update_text():
	dialog_text.text = lines[_line_idx]

# --- Portrait helpers ---
func _show_portrait(name: String):
	_hide_all_portraits()
	var portrait = dialog_panel.get_node_or_null(name)
	if portrait:
		portrait.visible = true

func _hide_all_portraits():
	for child in dialog_panel.get_children():
		if child is TextureRect:
			child.visible = false

func _set_visible(v: bool):
	dialog_panel.visible = v
	dialog_text.visible = v
