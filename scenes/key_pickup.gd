extends Area2D

@export var key_id: String = "boss_room_key"
@export var direct_gate_path: NodePath   # optional: drag your Gate node here

@onready var shape: CollisionShape2D = $CollisionShape2D

var _collected := false

func _ready() -> void:
	monitoring = true
	monitorable = true
	if shape and shape.shape == null:
		push_error("[KeyPickup] CollisionShape2D has no Shape!")
	# Try signals first
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(_dt: float) -> void:
	# Fallback: if we're overlapping the Player but signals didn't fire, trigger anyway
	if _collected: return
	var bodies := get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("Player"):
			_trigger_open(b)
			return

func _on_body_entered(body: Node) -> void:
	_trigger_open(body)

func _on_area_entered(area: Area2D) -> void:
	_trigger_open(area)

func _trigger_open(target: Node) -> void:
	if _collected: return
	if not target.is_in_group("Player"): return

	# Broadcast to all gates
	get_tree().call_group("KeyGates", "unlock_if_matches", key_id)

	# Optional direct open (useful while wiring)
	if direct_gate_path != NodePath(""):
		var g = get_node_or_null(direct_gate_path)
		if g and g.has_method("open"):
			g.open()

	# Hide / disable the key
	_collected = true
	if shape: shape.disabled = true
	monitoring = false
	visible = false
