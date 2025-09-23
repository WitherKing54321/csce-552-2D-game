# dialog_panel.gd
extends Panel
@onready var text: RichTextLabel = $Text  # or Label if that's what you used

func show_lines(lines: Array[String]) -> void:
	visible = true
	text.text = "\n".join(lines)  # shows text

func hide_box() -> void:
	visible = false
