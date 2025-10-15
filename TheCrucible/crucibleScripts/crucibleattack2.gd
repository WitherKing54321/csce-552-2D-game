extends BossState
class_name BossAttack2State

@export var attack_duration := 3.1  # 31 frames at 10 FPS
@export var damage := 20
@export var attack_speed := 4000  # dash speed

# Hitbox active window (frames 13–21)
var hit_start := 12 / 10.0  # 1.2 sec
var hit_end := 20 / 10.0   # 2.0 sec

var timer := 0.0
var has_hit_player := false
var locked_flip_h := false
var original_collision_mask := 0

func enter(Boss):
	print("Boss begins Attack 2")
	timer = 0.0
	has_hit_player = false
	locked_flip_h = Boss.sprite.flip_h

	if Boss.sprite:
		Boss.sprite.play("attack2")

	# Save original collision mask
	original_collision_mask = Boss.collision_mask

	# Connect hitbox
	var attack_area = Boss.get_node("attackarea2")
	if not attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.connect(_on_hitbox_body_entered)

	attack_area.get_node("CollisionShape2D").disabled = true
	attack_area.scale.x = 1 if not locked_flip_h else -1

	# Audio: single attack sound at start
	var attack_sfx = Boss.get_node_or_null("Attack2Sfx")
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.name = "Attack2Sfx"
		attack_sfx.stream = preload("res://Sounds/CrucibleSlam.wav") # set your path
		Boss.add_child(attack_sfx)
		attack_sfx.volume_db = 0.0
	else:
		if attack_sfx.playing:
			attack_sfx.stop()
	attack_sfx.play()

func physics_update(Boss, delta):
	timer += delta

	# Keep sprite facing locked direction
	Boss.sprite.flip_h = locked_flip_h

	var attack_area = Boss.get_node("attackarea2")
	var hitbox = attack_area.get_node("CollisionShape2D")

	# Activate hitbox
	hitbox.disabled = not (timer >= hit_start and timer <= hit_end)

	# --- Frame-based movement logic ---
	if timer < 1.0:  # Frames 0–9 (stationary)
		Boss.velocity = Vector2.ZERO
		Boss.collision_mask = original_collision_mask

	elif timer < 1.3:  # Frames 10–12 (jump upward)
		Boss.velocity.y = -500  # higher jump
		Boss.collision_mask = original_collision_mask

	elif timer < 1.5:  # Frames 13–14 (stationary)
		Boss.velocity = Vector2.ZERO
		Boss.collision_mask = original_collision_mask

	elif timer < 1.6:  # Frame 15 (dash midair)
		if Boss.player != null:
			var dir_to_player = Boss.player.position - Boss.position
			dir_to_player = dir_to_player.normalized()
			# Dash toward player, ignore collisions
			Boss.velocity = Vector2(dir_to_player.x * attack_speed, 0)
			Boss.collision_mask = 0  # ignore collisions during dash

	elif timer < 1.9:  # Frames 16–18 (stationary midair)
		Boss.velocity = Vector2.ZERO
		Boss.collision_mask = 0  # still ignore collisions to avoid sticking

	elif timer < 2.0:  # Frame 19 (slam down)
		Boss.velocity.y = 1400  # slam down
		Boss.collision_mask = 0  # ignore collisions while slamming

	else:  # Frames 20–30 (stationary)
		Boss.velocity = Vector2.ZERO
		Boss.collision_mask = original_collision_mask  # restore collisions

	# End attack
	if timer > attack_duration:
		hitbox.disabled = true
		Boss.collision_mask = original_collision_mask  # restore collisions
		# stop attack sound before switching state
		var s = Boss.get_node_or_null("Attack2Sfx")
		if s and s.playing:
			s.stop()
		Boss.change_state(BossIdleState.new())

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Boss hits the player!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		has_hit_player = true

func exit(Boss):
	var attack_area = Boss.get_node("attackarea2")
	attack_area.get_node("CollisionShape2D").disabled = true
	Boss.velocity = Vector2.ZERO
	Boss.collision_mask = original_collision_mask  # restore collisions

	# Stop sound on state change
	var s = Boss.get_node_or_null("Attack2Sfx")
	if s and s.playing:
		s.stop()
