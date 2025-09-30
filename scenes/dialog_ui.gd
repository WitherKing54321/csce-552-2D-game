extends CanvasLayer

@onready var panel: Panel = $DialogPanel
@onready var text: RichTextLabel = $DialogPanel/Text   # <- matches your tree

var lines: Array[String] = []
var i := 0

func _ready() -> void:
	add_to_group("dialog_ui")  # so NPCs can find this globally
	_set_dialog_visible(false)
	# Make sure this layer is on top of the world
	layer = max(layer, 10)
	print("[DialogUI] ready. panel=", panel, " text=", text)

func start_dialog(new_lines: Array[String]) -> void:
	lines = new_lines
	i = 0
	print("[DialogUI] start_dialog with ", lines.size(), " line(s)")
	_show_line()

func _input(event):
	if not panel.visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("advance_dialog"):
		i += 1
		_show_line()

func _show_line() -> void:
	if i >= lines.size():
		print("[DialogUI] finished")
		_set_dialog_visible(false)
		return
	text.text = lines[i]
	_set_dialog_visible(true)

func _set_dialog_visible(v: bool) -> void:
	panel.visible = v
	text.visible = v
	set_process_input(v)
