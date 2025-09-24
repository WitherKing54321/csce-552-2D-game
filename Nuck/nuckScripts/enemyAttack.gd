extends EnemyState
class_name EnemyAttackState

@export var attack_duration := 1.4
@export var damage := 25
@export var hit_start := 0.5  # seconds when the swing begins
@export var hit_end := 0.9    # seconds when the swing ends

# --- AUDIO ---
var ATTACK_STREAM: AudioStream = preload("res://Sounds/NuckAttack.wav")
var attack_sfx: AudioStreamPlayer2D
@export var attack_volume_db: float = +1.0   # tweak in Inspector

var timer := 0.0
var has_hit_player := false

func enter(Enemy):
	# connect hitbox
	var attack_area = Enemy.get_node("AttackArea")
	if not attack_area.body_entered.is_connected(_on_player_enter_hitbox):
		attack_area.body_entered.connect(_on_player_enter_hitbox)

	Enemy.get_node("AttackArea/CollisionShape2D").disabled = false
	Enemy.velocity.x = 10 * Enemy.dir.x
	Enemy.attack = true
	timer = 0.0
	Enemy.anim.play("nuckAttack")

	# --- Play attack sound once ---
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.stream = ATTACK_STREAM
		Enemy.add_child(attack_sfx)
	attack_sfx.volume_db = attack_volume_db
	attack_sfx.pitch_scale = randf_range(0.95, 1.05)  # small variation
	attack_sfx.play()

func physics_update(Enemy, delta):
	Enemy.dir = (Enemy.player.position - Enemy.position).normalized()
	if Enemy.dir.x < 0:
		Enemy.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif Enemy.dir.x > 0: 
		Enemy.get_node("AttackArea").set_scale(Vector2(-1, 1))

	Enemy.velocity.x = 10 * Enemy.dir.x
	timer += delta

	# end attack after duration
	if timer > attack_duration:
		Enemy.attack = false
		Enemy.get_node("AttackArea/CollisionShape2D").disabled = true
		Enemy.change_state(EnemyChaseState.new())

func _on_player_enter_hitbox(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Enemy hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
		has_hit_player = true
