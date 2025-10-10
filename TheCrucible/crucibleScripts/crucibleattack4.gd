extends BossState
class_name BossAttack4State

@export var attack_duration := 2.0  # 20 frames at 10 FPS
@export var damage := 20

# Hitbox active window (frames 10–13 → 1.0–1.3s)
var hit_start := 1.0
var hit_end := 1.3

var timer := 0.0
var has_hit_player := false
var locked_flip_h := false


func enter(Boss):
	print("Boss begins Attack 4")
	timer = 0.0
	has_hit_player = false
	locked_flip_h = Boss.sprite.flip_h

	if Boss.sprite:
		Boss.sprite.play("attack4")

	# Connect hitbox
	var attack_area = Boss.get_node("attackarea4")
	if not attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.connect(_on_hitbox_body_entered)

	# Disable hitbox initially
	attack_area.get_node("CollisionPolygon2D").disabled = true
	attack_area.scale.x = 1 if not locked_flip_h else -1


func physics_update(Boss, delta):
	timer += delta

	# Keep facing locked direction and stay still
	Boss.sprite.flip_h = locked_flip_h
	Boss.velocity = Vector2.ZERO

	var attack_area = Boss.get_node("attackarea4")
	var hitbox = attack_area.get_node("CollisionPolygon2D")

	# --- Hitbox activation window ---
	hitbox.disabled = not (timer >= hit_start and timer <= hit_end)

	# --- End attack after full duration ---
	if timer > attack_duration:
		hitbox.disabled = true
		Boss.change_state(BossIdleState.new())


func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Boss hits the player with Attack 4!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		has_hit_player = true


func exit(Boss):
	var attack_area = Boss.get_node("attackarea4")
	attack_area.get_node("CollisionPolygon2D").disabled = true
	Boss.velocity = Vector2.ZERO
