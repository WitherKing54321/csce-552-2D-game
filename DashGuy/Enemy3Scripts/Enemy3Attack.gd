extends EnemyState3
class_name EnemyAttackState3

var attack_duration := 1.2
var damage := 15
var hit_start := 0.6  # seconds when the swing begins
var hit_end := 0.9    # seconds when the swing ends

# --- AUDIO ---
var ATTACK_STREAM: AudioStream = preload("res://Sounds/CloakAttack.wav")
var attack_sfx: AudioStreamPlayer2D
var attack_volume_db: float = +0.1

var timer := 0.0
var has_hit_player := false

# --- movement window during attack ---
var move_start := 0.6
var move_end := 0.9

# --- store locked facing direction ---
var locked_dir := Vector2.ZERO

func enter(Enemy3):
	var attack_area = Enemy3.get_node("AttackArea")
	if not attack_area.body_entered.is_connected(_on_player_enter_hitbox):
		attack_area.body_entered.connect(_on_player_enter_hitbox)

	Enemy3.get_node("AttackArea/CollisionShape2D").disabled = true
	Enemy3.attack = true
	timer = 0.0
	Enemy3.anim.play("attack")

	# --- lock direction at attack start ---
	locked_dir = (Enemy3.player.position - Enemy3.position).normalized()

	# Flip attack area once based on locked direction
	if locked_dir.x < 0:
		Enemy3.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif locked_dir.x > 0:
		Enemy3.get_node("AttackArea").set_scale(Vector2(-1, 1))

	# --- Play attack sound once ---
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.stream = ATTACK_STREAM
		Enemy3.add_child(attack_sfx)
	attack_sfx.volume_db = attack_volume_db
	attack_sfx.pitch_scale = randf_range(0.95, 1.05)
	attack_sfx.play()

func physics_update(Enemy3, delta):
	timer += delta

	# --- Movement only during 0.6s -> 0.9s ---
	if timer >= move_start and timer <= move_end:
		Enemy3.velocity.x = 300 * locked_dir.x
	else:
		Enemy3.velocity.x = 0

	# --- Activate hitbox only during swing window ---
	var hitbox = Enemy3.get_node("AttackArea/CollisionShape2D")
	hitbox.disabled = not (timer >= hit_start and timer <= hit_end)

	# --- End attack ---
	if timer > attack_duration:
		Enemy3.attack = false
		hitbox.disabled = true
		Enemy3.change_state(EnemyChaseState3.new())

func _on_player_enter_hitbox(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Enemy hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
		has_hit_player = true
