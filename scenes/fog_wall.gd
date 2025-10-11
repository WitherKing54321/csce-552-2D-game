extends Node2D

@export var boss_path: NodePath
@onready var sprite := $Sprite2D
@onready var col := $StaticBody2D/CollisionShape2D  # adjust to your blocker node

var boss: Node

func _ready() -> void:
	boss = get_node_or_null(boss_path)
	if boss == null:
		push_warning("FogWall: boss_path not assigned (drag TheCrucible onto boss_path).")
		return
	if boss.has_signal("boss_defeated"):
		boss.connect("boss_defeated", Callable(self, "_on_boss_defeated"))
	else:
		push_warning("FogWall: Boss has no 'boss_defeated' signal.")

func _on_boss_defeated() -> void:
	if col: col.disabled = true
	if sprite:
		var tween = create_tween()
		tween.tween_property(
			sprite, "modulate",
			Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.0),
			1.2
		)
		await tween.finished
	queue_free()
