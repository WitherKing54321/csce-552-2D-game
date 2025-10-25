extends Area2D

@export var player_group: String = "player"

# --- Text displayed when player is near ---
@export_multiline var controls_bbcode := """[b]Controls[/b]
Move: WASD or arrow keys
Double Jump: W
Attack: X or /
Glide: Z or '.'(Period)
Interact: E, 'Enter' or 'Spacebar'
Mute Music: M
Pause: Esc
"""

# --- Visual settings ---
@export var font_size: int = 10
@export var auto_width: int = 260
@export var bubble_offset: Vector2 = Vector2(0, 0)
@export var use_bbcode: bool = true
@export var custom_font: Font

# NEW: bubble look (tweak these in the Inspector)
@export var bubble_bg_color: Color = Color(0, 0, 0, 0.80)   # darker = higher alpha
@export var bubble_corner_radius: int = 10
@export var bubble_padding: int = 8                          # internal margins

# --- Internal nodes ---
@onready var bubble: Node2D = $Bubble
@onready var panel: PanelContainer = $Bubble/PanelContainer
@onready var text: RichTextLabel = $Bubble/PanelContainer/MarginContainer/Text
@onready var margins: MarginContainer = $Bubble/PanelContainer/MarginContainer

func _ready() -> void:
	# Position & hide bubble until the player enters
	bubble.position = bubble_offset
	bubble.visible = false

	# Panel style (dark background)
	_apply_panel_style()

	# Configure label
	text.bbcode_enabled = use_bbcode
	text.text = controls_bbcode
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.fit_content = true
	text.size.x = auto_width

	# Font overrides
	text.add_theme_font_size_override("normal_font_size", font_size)
	if custom_font:
		text.add_theme_font_override("normal_font", custom_font)

	# Connect body enter/exit (safe if already wired in editor)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

func _apply_panel_style() -> void:
	# Create a dark, rounded background for the PanelContainer
	var sb := StyleBoxFlat.new()
	sb.bg_color = bubble_bg_color
	sb.corner_radius_top_left = bubble_corner_radius
	sb.corner_radius_top_right = bubble_corner_radius
	sb.corner_radius_bottom_left = bubble_corner_radius
	sb.corner_radius_bottom_right = bubble_corner_radius
	panel.add_theme_stylebox_override("panel", sb)

	# Padding inside the bubble
	margins.add_theme_constant_override("margin_left", bubble_padding)
	margins.add_theme_constant_override("margin_right", bubble_padding)
	margins.add_theme_constant_override("margin_top", bubble_padding)
	margins.add_theme_constant_override("margin_bottom", bubble_padding)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group):
		_show_bubble()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(player_group):
		_hide_bubble()

func _show_bubble() -> void:
	bubble.visible = true
	# Only fade the container node; text stays crisp because we don't modulate the Label
	bubble.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(bubble, "modulate:a", 1.0, 0.15)

func _hide_bubble() -> void:
	var tw := create_tween()
	tw.tween_property(bubble, "modulate:a", 0.0, 0.12)
	await tw.finished
	bubble.visible = false
