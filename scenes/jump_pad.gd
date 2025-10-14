# jump_pad.gd — attach to your Area2D (the node with the CollisionShape2D)
extends Area2D

signal pad_used(body: Node)

@export var power: float = 1300.0
@export var cooldown: float = 0.15
@export var direction: Vector2 = Vector2.UP

var PAD_STREAM: AudioStream = preload("res://Sounds/Boing.wav")
var pad_sfx: AudioStreamPlayer2D

@onready var cd_timer: Timer = $Timer if has_node("Timer") else null
@onready var anim: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

func _ready() -> void:
	monitoring = true
	monitorable = true
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if cd_timer and cd_timer.time_left > 0.0:
		return
	if not body.is_in_group("player"):
		return

	var impulse: Vector2 = direction.normalized() * power
	_launch(body, impulse)

	# play sound like EnemyDeathState style
	if pad_sfx == null:
		pad_sfx = AudioStreamPlayer2D.new()
		pad_sfx.stream = PAD_STREAM
		add_child(pad_sfx)
	pad_sfx.stop()
	pad_sfx.play()

	if cd_timer:
		cd_timer.start(cooldown)

func _launch(body: Node, impulse: Vector2) -> void:
	if body.has_method("launch_from_pad"):
		body.launch_from_pad(impulse)
	else:
		if body is CharacterBody2D:
			var c := body as CharacterBody2D
			var v: Vector2 = c.velocity
			v.y = -abs(impulse.y if impulse.y != 0.0 else power)
			c.velocity = v
		elif body is RigidBody2D:
			(body as RigidBody2D).apply_impulse(impulse)

	if anim:
		anim.play("launch")

	pad_used.emit(body)
