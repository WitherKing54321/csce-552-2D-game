extends EnemyState2
class_name EnemyAttackState2

var attack_duration := 1.8
var damage := 50
var hit_start := 1.2  # seconds when the swing begins
var hit_end := 1.4    # seconds when the swing ends

# --- AUDIO ---
var ATTACK2_STREAM: AudioStream = preload("res://Sounds/ZweihanderAttack.wav")
var attack2_sfx: AudioStreamPlayer2D

var timer := 0.0
var has_hit_player := false

func enter(Enemy2):
	# connect hitbox
	var attack_area = Enemy2.get_node("AttackArea")
	if not attack_area.body_entered.is_connected(_on_player_enter_hitbox):
		attack_area.body_entered.connect(_on_player_enter_hitbox)

	Enemy2.get_node("AttackArea/CollisionShape2D").disabled = true
	#Enemy2.velocity.x = 10 * Enemy2.dir.x
	Enemy2.attack = true
	timer = 0.0
	Enemy2.anim.play("enemy2Attack")

	# --- Play attack sound once ---
	if attack2_sfx == null:
		attack2_sfx = AudioStreamPlayer2D.new()
		attack2_sfx.stream = ATTACK2_STREAM
		Enemy2.add_child(attack2_sfx)
	attack2_sfx.volume_db = 0.0
	attack2_sfx.pitch_scale = randf_range(0.95, 1.05)  # small variation
	attack2_sfx.play()

func physics_update(Enemy2, delta):
	Enemy2.dir = (Enemy2.player.position - Enemy2.position).normalized()
	if Enemy2.dir.x < 0:
		Enemy2.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif Enemy2.dir.x > 0: 
		Enemy2.get_node("AttackArea").set_scale(Vector2(-2, 1))

	Enemy2.velocity.x = 10 * Enemy2.dir.x
	timer += delta

	# --- Activate hitbox only during the swing window ---
	var hitbox = Enemy2.get_node("AttackArea/CollisionShape2D")
	if timer >= hit_start and timer <= hit_end:
		hitbox.disabled = false
	else:
		hitbox.disabled = true

	# --- End attack after total duration ---
	if timer > attack_duration:
		Enemy2.attack = false
		hitbox.disabled = true
		Enemy2.change_state(EnemyChaseState2.new())


func _on_player_enter_hitbox(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Enemy hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
		has_hit_player = true
