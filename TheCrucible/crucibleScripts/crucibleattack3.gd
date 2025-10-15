extends BossState
class_name BossAttack3State

@export var attack_duration := 2.9  # total duration
@export var damage := 20
@export var attack_speed := 270  # forward movement speed

# Hitbox active window (1.2s–2.1s)
var hit_start := 1.2
var hit_end := 2.1

var timer := 0.0
var has_hit_player := false
var locked_flip_h := false
var original_collision_mask := 0

func enter(Boss):
	print("Boss begins Attack 3")
	timer = 0.0
	has_hit_player = false
	locked_flip_h = Boss.sprite.flip_h

	if Boss.sprite:
		Boss.sprite.play("attack3")

	# Save original collision mask
	original_collision_mask = Boss.collision_mask

	# Connect hitbox
	var attack_area = Boss.get_node("attackarea3")
	if not attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.connect(_on_hitbox_body_entered)

	# Disable hitbox initially
	attack_area.get_node("CollisionPolygon2D").disabled = true
	attack_area.scale.x = -1 if not locked_flip_h else 1

	# --- Audio: single attack sound at start ---
	var attack_sfx = Boss.get_node_or_null("Attack3Sfx")
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.name = "Attack3Sfx"
		attack_sfx.stream = preload("res://Sounds/CrucibleCrawl.wav") # set your path
		Boss.add_child(attack_sfx)
		attack_sfx.volume_db = 0.0
	else:
		if attack_sfx.playing:
			attack_sfx.stop()
	attack_sfx.play()

func physics_update(Boss, delta):
	timer += delta

	# Keep facing locked direction
	Boss.sprite.flip_h = locked_flip_h

	var attack_area = Boss.get_node("attackarea3")
	var hitbox = attack_area.get_node("CollisionPolygon2D")

	# --- Hitbox activation ---
	hitbox.disabled = not (timer >= hit_start and timer <= hit_end)

	# --- Movement logic ---
	if timer >= hit_start and timer <= hit_end:
		var direction = -1 if locked_flip_h else 1
		Boss.velocity.x = direction * attack_speed
	else:
		Boss.velocity = Vector2.ZERO

	# --- End attack ---
	if timer > attack_duration:
		hitbox.disabled = true
		Boss.collision_mask = original_collision_mask
		# stop attack sound before leaving state
		var attack_sfx = Boss.get_node_or_null("Attack3Sfx")
		if attack_sfx and attack_sfx.playing:
			attack_sfx.stop()
		Boss.change_state(BossIdleState.new())

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Boss hits the player with Attack 3!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		has_hit_player = true

func exit(Boss):
	var attack_area = Boss.get_node("attackarea3")
	attack_area.get_node("CollisionPolygon2D").disabled = true
	Boss.velocity = Vector2.ZERO
	Boss.collision_mask = original_collision_mask

	# Stop attack sound on state change
	var attack_sfx = Boss.get_node_or_null("Attack3Sfx")
	if attack_sfx and attack_sfx.playing:
		attack_sfx.stop()
