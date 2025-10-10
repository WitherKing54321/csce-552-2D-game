extends BossState
class_name BossIdleState

@export var patrol_speed := 15
@export var attack_cooldown := 3.0

var attack_timer := 0.0

func enter(Boss):
	print("Enter Idle/Chase State")
	attack_timer = 0.0
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
	else:
		Boss.velocity.x = 0

	# --- Attack cooldown ---
	if distance < Boss.chase_range:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			attack_timer = 0
			Boss.choose_attack()
