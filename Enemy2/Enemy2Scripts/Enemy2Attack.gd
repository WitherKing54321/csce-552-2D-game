extends EnemyState2
class_name EnemyAttackState2

var attack_duration := 1.4
var damage := 1
var hit_start := 0.7  # seconds when the swing begins
var hit_end := 0.9    # seconds when the swing ends

# --- AUDIO ---
var ATTACK_STREAM: AudioStream = preload("res://Sounds/NuckAttack.wav")
var attack_sfx: AudioStreamPlayer2D
var attack_volume_db: float = +1.0   # tweak in Inspector

var timer := 0.0
var has_hit_player := false

func enter(Enemy2):
	# connect hitbox
	var attack_area = Enemy2.get_node("AttackArea")
	if not attack_area.body_entered.is_connected(_on_player_enter_hitbox):
		attack_area.body_entered.connect(_on_player_enter_hitbox)

	Enemy2.get_node("AttackArea/CollisionShape2D").disabled = false
	Enemy2.velocity.x = 10 * Enemy2.dir.x
	Enemy2.attack = true
	timer = 0.0
	Enemy2.anim.play("enemy2Attack")

	# --- Play attack sound once ---
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.stream = ATTACK_STREAM
		Enemy2.add_child(attack_sfx)
	attack_sfx.volume_db = attack_volume_db
	attack_sfx.pitch_scale = randf_range(0.95, 1.05)  # small variation
	attack_sfx.play()

func physics_update(Enemy2, delta):
	Enemy2.dir = (Enemy2.player.position - Enemy2.position).normalized()
	if Enemy2.dir.x < 0:
		Enemy2.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif Enemy2.dir.x > 0: 
		Enemy2.get_node("AttackArea").set_scale(Vector2(-1, 1))

	Enemy2.velocity.x = 10 * Enemy2.dir.x
	timer += delta

	# end attack after duration
	if timer > attack_duration:
		Enemy2.attack = false
		Enemy2.get_node("AttackArea/CollisionShape2D").disabled = true
		Enemy2.change_state(EnemyChaseState2.new())

func _on_player_enter_hitbox(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Enemy hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
		has_hit_player = true
