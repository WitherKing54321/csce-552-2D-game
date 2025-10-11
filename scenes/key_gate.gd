extends Node2D

@export var required_key: String = "boss_room_key"

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var anim: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var col: CollisionShape2D = $StaticBody2D/CollisionShape2D   # matches your boss fog wall

var is_open := false

func _ready() -> void:
	add_to_group("KeyGates")   # so KeyPickup can broadcast to us
	add_to_group("Resettable") # optional, for in-place world reset
	close()                    # always start closed

# Called by KeyPickup via call_group
func unlock_if_matches(id: String) -> void:
	print("[KeyGate] received:", id, " required:", required_key)
	if id == required_key:
		open()

func open() -> void:
	if is_open: return
	is_open = true
	if col: col.disabled = true

	# match your boss fog wall style (fade then hide)
	if anim and anim.has_animation("open"):
		anim.play("open")
	elif sprite:
		var t := create_tween()
		t.tween_property(sprite, "modulate",
			Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.0), 0.8)
		await t.finished
	visible = false
	# queue_free()  # use this instead of visible=false if you want it removed

func close() -> void:
	is_open = false
	if col: col.disabled = false
	visible = true
	if anim and anim.is_playing(): anim.stop()

# If you respawn WITHOUT reloading the scene:
func on_world_reset() -> void:
	close()
