extends CharacterBody2D
class_name Enemy3

var speed := 70
var attack_range := 70
var chase_range := 100
var gravity := 800
var health = 100
var player: Node = null
var anim: AnimatedSprite2D
var state: EnemyState3 = null
var attack = false
var directionFacingRight = true
var dir = 0
var invincible_timer = 0.0
var death = false   # <-- keep as a property, not shadowed

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim = $Enemy3AnimatedSprite2D
	change_state(EnemyIdleState3.new())
	
	var hurtbox3 = get_node("hurtbox3")
	hurtbox3.area_entered.connect(_on_hurtbox_3_body_entered)
	
	
func _on_hurtbox_3_body_entered(area: Node): 
	print("Bob feels the blade")
	if area.is_in_group("player_sword") and invincible_timer <= 0:
		take_damage(10)
		
func take_damage(amount: int):
	health -= amount
	invincible_timer = 0.3  # 0.3s of invincibility
	var hurt_state = EnemyHurtState3.new()
	hurt_state.damage_taken = amount
	change_state(hurt_state)
	if health <= 0 and not death:
		death = true   # <-- fixed (no "var")
		change_state(EnemyDeathState3.new())

func _physics_process(delta):
	invincible_timer -= delta  # Countdown invincibility timer

	if state:
		state.physics_update(self, delta)

	velocity.y += gravity * delta
	move_and_slide()

	# Update facing direction if not in death state
	if not death:
		if velocity.x < 0:
			directionFacingRight = true
		elif velocity.x > 0:
			directionFacingRight = false
		$Enemy3AnimatedSprite2D.flip_h = not directionFacingRight

func change_state(new_state: EnemyState3):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
