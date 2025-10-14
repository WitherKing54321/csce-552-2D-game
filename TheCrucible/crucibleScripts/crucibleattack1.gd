extends BossState
class_name BossAttack1State

@export var attack_duration := 1.4
@export var damage := 20
@export var hit_start := 0.93
@export var hit_end := 0.98
@export var attack_speed := 300  # moves backward while hitting

var timer := 0.0
var has_hit_player := false
var locked_flip_h := false  # Stores sprite direction at attack start

func enter(Boss):
	print("Boss begins Attack 1")
	timer = 0.0
	has_hit_player = false

	# Lock current sprite direction
	locked_flip_h = Boss.sprite.flip_h

	if Boss.sprite:
		Boss.sprite.play("attack1")

	# Connect hitbox
	var attack_area = Boss.get_node("attackarea1")
	if not attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.connect(_on_hitbox_body_entered)

	attack_area.get_node("CollisionShape2D").disabled = true

	# Flip hitbox to match locked direction
	attack_area.scale.x = -1 if not locked_flip_h else 1

	# --- Audio: single attack sound at start ---
	var attack_sfx = Boss.get_node_or_null("Attack1Sfx")
	if attack_sfx == null:
		attack_sfx = AudioStreamPlayer2D.new()
		attack_sfx.name = "Attack1Sfx"
		attack_sfx.stream = preload("res://Sounds/CrucibleEnergyBeam.wav") # set your path
		Boss.add_child(attack_sfx)
	else:
		if attack_sfx.playing:
			attack_sfx.stop()
	attack_sfx.play()

func physics_update(Boss, delta):
	timer += delta

	# Keep sprite facing locked direction
	Boss.sprite.flip_h = locked_flip_h

	var attack_area = Boss.get_node("attackarea1")
	var hitbox = attack_area.get_node("CollisionShape2D")

	# Activate hitbox during swing window
	hitbox.disabled = not (timer >= hit_start and timer <= hit_end)

	# Stop horizontal movement while attacking
	Boss.velocity.x = 0

	# End attack when timer exceeds duration
	if timer > attack_duration:
		hitbox.disabled = true
		Boss.change_state(BossIdleState.new())

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Boss hits the player!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		has_hit_player = true

func exit(Boss):
	var attack_area = Boss.get_node("attackarea1")
	attack_area.get_node("CollisionShape2D").disabled = true
	Boss.velocity.x = 0

	# Stop attack sound on state change
	var attack_sfx = Boss.get_node_or_null("Attack1Sfx")
	if attack_sfx and attack_sfx.playing:
		attack_sfx.stop()
