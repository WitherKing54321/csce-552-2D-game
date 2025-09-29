extends Area2D

@export var lines := [
	"Hello there!",
	"Beware the spikes.",
	"Good luck!"
]

var dialog_ui: Node = null

func _ready() -> void:
	# Find the DialogUI by group (set in DialogUI.gd)
	dialog_ui = get_tree().get_first_node_in_group("dialog_ui")
	if dialog_ui:
		print("[Butler] found DialogUI: ", dialog_ui)
	else:
		push_error("[Butler] Could not find any node in group 'dialog_ui'. Is DialogUI in the scene?")

# Make sure your Area2D has the body_entered signal connected to THIS exact function name.
func _on_Butler_body_entered(body: Node) -> void:
	if not dialog_ui:
		return
	if body.is_in_group("player") or body.name == "Player":
		if dialog_ui.has_method("start_dialog"):
			print("[Butler] starting dialog…")
			dialog_ui.start_dialog(lines)
		else:
			push_error("[Butler] DialogUI is missing start_dialog()")
