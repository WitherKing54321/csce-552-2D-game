extends EnemyState3
class_name EnemyAttackState3

var attack_duration := 0.8
var damage := 0
var hit_start := 0.0  # seconds when the swing begins
var hit_end := 0.5    # seconds when the swing ends

# --- AUDIO ---
var ATTACK_STREAM: AudioStream = preload("res://Sounds/NuckAttack.wav")
var attack_sfx: AudioStreamPlayer2D
var attack_volume_db: float = +1.0   # tweak in Inspector

var timer := 0.0
var has_hit_player := false

func enter(Enemy3):
	# connect hitbox
	var attack_area = Enemy3.get_node("AttackArea")
	if not attack_area.body_entered.is_connected(_on_player_enter_hitbox):
		attack_area.body_entered.connect(_on_player_enter_hitbox)

	Enemy3.get_node("AttackArea/CollisionShape2D").disabled = true
	#Enemy3.velocity.x = 10 * Enemy3.dir.x
	Enemy3.attack = true
	timer = 0.0
	Enemy3.anim.play("attack")

	# --- Play attack sound once ---
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.stream = ATTACK_STREAM
		Enemy3.add_child(attack_sfx)
	attack_sfx.volume_db = attack_volume_db
	attack_sfx.pitch_scale = randf_range(0.95, 1.05)  # small variation
	attack_sfx.play()

func physics_update(Enemy3, delta):
	Enemy3.dir = (Enemy3.player.position - Enemy3.position).normalized()
	if Enemy3.dir.x < 0:
		Enemy3.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif Enemy3.dir.x > 0: 
		Enemy3.get_node("AttackArea").set_scale(Vector2(-1, 1))

	Enemy3.velocity.x = 100 * Enemy3.dir.x
	timer += delta

	# --- Activate hitbox only during the swing window ---
	var hitbox = Enemy3.get_node("AttackArea/CollisionShape2D")
	if timer >= hit_start and timer <= hit_end:
		hitbox.disabled = false
	else:
		hitbox.disabled = true

	# --- End attack after total duration ---
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
