# KeyCircle.gd
extends Node2D

@export var radius: float = 12.0
@export var color: Color = Color(1.0, 0.85, 0.1, 1.0) # gold-ish
@export var outline_color: Color = Color(0, 0, 0, 0.5)
@export var outline_width: float = 2.0

func _draw() -> void:
	# Fill
	draw_circle(Vector2.ZERO, radius, color)
	# Outline (optional)
	if outline_width > 0.0:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, outline_color, outline_width, true)

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED or what == NOTIFICATION_VISIBILITY_CHANGED:
		queue_redraw()
