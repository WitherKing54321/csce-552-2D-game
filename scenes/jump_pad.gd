# jump_pad.gd — attach to your Area2D (the node with the CollisionShape2D)
extends Area2D

@export var power: float = 1300.0        # launch strength
@export var cooldown: float = 0.15      # debounce
@export var direction: Vector2 = Vector2.UP  # keep as UP for vertical

@onready var cd_timer: Timer = $Timer if has_node("Timer") else null
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null
@onready var anim: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

func _ready() -> void:
	# Make sure the Area2D is monitoring
	monitoring = true
	monitorable = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Cooldown / debounce
	if cd_timer and cd_timer.time_left > 0.0:
		return
	# Only affect the player group
	if not body.is_in_group("player"):
		return

	var impulse: Vector2 = direction.normalized() * power
	_launch(body, impulse)

	if cd_timer:
		cd_timer.start(cooldown)

func _launch(body: Node, impulse: Vector2) -> void:
	# Preferred: let Player expose a method
	if body.has_method("launch_from_pad"):
		body.launch_from_pad(impulse)
		return

	# CharacterBody2D fallback
	if body is CharacterBody2D:
		var c := body as CharacterBody2D
		var v: Vector2 = c.velocity        # <- explicitly typed
		# Replace vertical component; keep horizontal
		v.y = -abs(impulse.y if impulse.y != 0.0 else power)
		c.velocity = v
	# RigidBody2D fallback
	elif body is RigidBody2D:
		(body as RigidBody2D).apply_impulse(impulse)

	# Juice (optional)
	if anim:
		anim.play("launch")
	if sfx:
		sfx.stop()
		sfx.play()
