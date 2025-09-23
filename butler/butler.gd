extends Node2D

@export var lines: Array[String] = [
	"Start digging in your butt twin!"
]

@export var dialog_text_path: NodePath
@onready var dialog_text: RichTextLabel = get_node_or_null(dialog_text_path)

@onready var zone: Area2D = $TalkZone

func _ready() -> void:
	if dialog_text:
		dialog_text.visible = false  # start hidden
	if not zone.body_entered.is_connected(_on_zone_body_entered):
		zone.body_entered.connect(_on_zone_body_entered)
	if not zone.body_exited.is_connected(_on_zone_body_exited):
		zone.body_exited.connect(_on_zone_body_exited)

func _on_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player") and dialog_text:
		dialog_text.text = "\n".join(lines)
		dialog_text.visible = true

func _on_zone_body_exited(body: Node) -> void:
	if body.is_in_group("player") and dialog_text:
		dialog_text.visible = false
