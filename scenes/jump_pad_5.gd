# jump_pad.gd — attach to your Area2D
extends Area2D

@export var power: float = 2000.0
@export var cooldown: float = 0.15
@export var direction: Vector2 = Vector2.UP   # used when use_rotation == false
@export var use_rotation: bool = true         # rotate the pad to aim
@export var replace_velocity: bool = true     # force exact launch dir
@export var player_group: String = "player"   # optional: only boost bodies in this group

# --- AUDIO ---
var PAD_STREAM: AudioStream = preload("res://Sounds/Boing.wav")
var pad_sfx: AudioStreamPlayer2D

var _cooling_down := false

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_shape_entered.connect(_on_body_shape_entered)

	# Create audio player once
	if pad_sfx == null:
		pad_sfx = AudioStreamPlayer2D.new()
		pad_sfx.stream = PAD_STREAM
		pad_sfx.bus = "Master"
		pad_sfx.volume_db = 0.0
		pad_sfx.attenuation = 0.0
		add_child(pad_sfx)

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_idx: int, local_shape_idx: int) -> void:
	if _cooling_down:
		return
	if body is CharacterBody2D == false:
		return
	if player_group != "" and not body.is_in_group(player_group):
		return
	if body.has_meta("pad_boosting") and body.get_meta("pad_boosting"):
		return

	var c := body as CharacterBody2D
	var dir := _aim_dir()
	if dir == Vector2.ZERO:
		return

	c.set_meta("pad_boosting", true)
	var old_snap := c.floor_snap_length
	c.floor_snap_length = 0.0

	if replace_velocity:
		c.velocity = dir * power
	else:
		var v := c.velocity
		var perp := v - v.project(dir)
		c.velocity = perp + dir * power

	# Play sound like EnemyDeathState style
	if pad_sfx:
		pad_sfx.stop()
		pad_sfx.play()

	set_deferred("monitoring", false)
	_cooling_down = true

	await get_tree().process_frame
	await get_tree().create_timer(cooldown).timeout

	c.floor_snap_length = old_snap
	c.set_meta("pad_boosting", false)
	monitoring = true
	_cooling_down = false

func _aim_dir() -> Vector2:
	# Node "up" in global space (rotate the pad), or fixed exported vector
	return (-global_transform.y if use_rotation else direction).normalized()
