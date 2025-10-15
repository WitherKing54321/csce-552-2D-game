extends CharacterBody2D
class_name Boss

var speed := 50
var attack_range := 20
var chase_range := 200
var gravity := 800
var health := 10
var player: Node = null
var sprite: AnimatedSprite2D
var state: BossState = null
var directionFacingRight := true
var invincible_timer := 0.0
var death := false

@export var contact_damage := 10

var attack_weights = {
	"attack1": 2.5,
	"attack2": 2.5,
	"attack3": 2.5,
	"attack4": 2.5
}

func _ready():
	player = get_tree().get_first_node_in_group("player")
	sprite = $AnimatedSprite2D
	change_state(BossIdleState.new())

	var hurtbox = get_node("hurtbox")
	hurtbox.area_entered.connect(_on_hurtbox_body_entered)

	var attack_area0 = get_node("attackarea0")
	if not attack_area0.body_entered.is_connected(_on_attackarea0_body_entered):
		attack_area0.body_entered.connect(_on_attackarea0_body_entered)

func _on_hurtbox_body_entered(area: Node):
	if area.is_in_group("player_sword") and invincible_timer <= 0:
		take_damage(10)

func _on_attackarea0_body_entered(body: Node):
	if body.is_in_group("player"):
		print("Boss deals contact damage!")
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)

func take_damage(amount: int):
	print("Boss takes damage")
	health -= amount

	# play hurt sound
	var hurt_sfx = get_node_or_null("HurtSfx")
	if hurt_sfx == null:
		hurt_sfx = AudioStreamPlayer2D.new()
		hurt_sfx.name = "HurtSfx"
		hurt_sfx.stream = preload("res://Sounds/CrucibleHurt.wav") # set your path
		add_child(hurt_sfx)
	else:
		if hurt_sfx.playing:
			hurt_sfx.stop()
	hurt_sfx.play()

	flash_white()
	if health <= 0 and not death:
		death = true
		change_state(BossDeathState.new())

func flash_white():
	sprite.modulate = Color(2, 2, 2, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

func _physics_process(delta):
	invincible_timer -= delta
	if state:
		state.physics_update(self, delta)

	velocity.y += gravity * delta
	move_and_slide()

	if velocity.x > 0:
		directionFacingRight = false
	elif velocity.x < 0:
		directionFacingRight = true

	if sprite:
		sprite.flip_h = not directionFacingRight

func change_state(new_state: BossState):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)

func choose_attack():
	var roll = randf()
	var total = 0.0

	var sum_weights = 0.0
	for w in attack_weights.values():
		sum_weights += w

	for name in attack_weights.keys():
		total += attack_weights[name] / sum_weights
		if roll <= total:
			print("Chosen attack:", name)
			match name:
				"attack1":
					change_state(BossAttack1State.new())
				"attack2":
					change_state(BossAttack2State.new())
				"attack3":
					change_state(BossAttack3State.new())
				"attack4":
					change_state(BossAttack4State.new())
				_:
					change_state(BossIdleState.new())
			return

	change_state(BossIdleState.new())

signal boss_defeated

func die():
	print("Boss defeated!")
	emit_signal("boss_defeated")

	# stop hurt sound if it is still playing
	var s = get_node_or_null("HurtSfx")
	if s and s.playing:
		s.stop()

	queue_free()
