extends Area2D

@export var power: float = 2000.0
@export var cooldown: float = 0.15
@export var direction: Vector2 = Vector2.UP   # used when use_rotation == false
@export var use_rotation: bool = true         # rotate the pad to aim
@export var replace_velocity: bool = true     # force exact launch dir
@export var player_group: String = "player"   # optional: only boost bodies in this group

var _cooling_down := false

func _ready() -> void:
	monitoring = true
	monitorable = true
	# Use shape signal to avoid duplicate body_entered calls from multiple shapes
	body_shape_entered.connect(_on_body_shape_entered)

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_idx: int, local_shape_idx: int) -> void:
	if _cooling_down:
		return
	if body is CharacterBody2D == false:
		return
	if player_group != "" and not body.is_in_group(player_group):
		# Optional filter so we don't boost enemies or physics debris
		return
	# If another pad is already boosting this body, ignore
	if body.has_meta("pad_boosting") and body.get_meta("pad_boosting"):
		return

	var c := body as CharacterBody2D
	var dir := _aim_dir()
	if dir == Vector2.ZERO:
		return

	# Mark as boosting so other pads won't interfere for a moment
	c.set_meta("pad_boosting", true)

	# TEMP disable floor snap so move_and_slide doesn't project velocity upward
	var old_snap := c.floor_snap_length
	c.floor_snap_length = 0.0

	if replace_velocity:
		c.velocity = dir * power
	else:
		var v := c.velocity
		var perp := v - v.project(dir)
		c.velocity = perp + dir * power

	# Prevent this pad from re-triggering while overlapping
	set_deferred("monitoring", false)
	_cooling_down = true

	# Re-enable things after a short delay
	await get_tree().process_frame            # let one physics tick apply the new velocity
	await get_tree().create_timer(cooldown).timeout

	# restore
	c.floor_snap_length = old_snap
	c.set_meta("pad_boosting", false)
	monitoring = true
	_cooling_down = false

func _aim_dir() -> Vector2:
	# Node "up" in global space (rotate the pad), or fixed exported vector
	return (-global_transform.y if use_rotation else direction).normalized()
