extends BossState
class_name BossIdleState

@export var patrol_speed := 25
@export var min_attack_cooldown := 0.5
@export var max_attack_cooldown := 2.5

var attack_timer := 0.0
var next_attack_time := 0.0

func enter(Boss):
	print("Enter Chase State")
	attack_timer = 0.0
	next_attack_time = randf_range(min_attack_cooldown, max_attack_cooldown)
	if Boss.sprite:
		Boss.sprite.play("idle")

func physics_update(Boss, delta):
	if not Boss.player:
		return

	# --- Move toward player ---
	var dir_to_player = Boss.player.position - Boss.position
	var distance = dir_to_player.length()

	if distance > Boss.attack_range:
		var move_dir = sign(dir_to_player.x)
		Boss.velocity.x = move_dir * patrol_speed
		Boss.sprite.flip_h = move_dir < 0
	else:
		Boss.velocity.x = 0

	# --- Randomized attack timing ---
	if distance < Boss.chase_range:
		attack_timer += delta
		if attack_timer >= next_attack_time:
			attack_timer = 0.0
			next_attack_time = randf_range(min_attack_cooldown, max_attack_cooldown)
			Boss.choose_attack()
