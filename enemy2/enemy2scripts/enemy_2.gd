extends CharacterBody2D
class_name Enemy2
var speed := 50
var attack_range := 20
var chase_range := 60
var gravity := 800
var health = 100
var player: Node = null
var anim: AnimatedSprite2D
var state: EnemyState2 = null
var attack = false
var directionFacingRight = true
var dir = 0
var invincible_timer = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim = $Enemy2AnimatedSprite2D  # <-- use AnimatedSprite2D
	change_state(EnemyIdleState2.new())
	
	var hurtbox2 = get_node("hurtbox2")
	hurtbox2.area_entered.connect(_on_hurtbox_2_body_entered)
	
	
func _on_hurtbox_2_body_entered(area: Node): 
	print("Bob feels the blade")
	if area.is_in_group("player_sword") and invincible_timer <= 0:
		take_damage(10)
		
func take_damage(amount: int):
	print("Bob takes damage")
	health -= amount
	invincible_timer = 0.3  # 1 second of invincibility
	var hurt_state = EnemyHurtState2.new()
	hurt_state.damage_taken = amount
	change_state(hurt_state)
	if health <= 0:
		change_state(EnemyDeathState2.new())

func _physics_process(delta):
	invincible_timer -= delta  # Countdown invincibility timer
	if state:
		state.physics_update(self, delta)
	velocity.y += gravity * delta
	move_and_slide()
	# Update facing direction based on X velocity
	if velocity.x < 0:
		directionFacingRight = true
	elif velocity.x > 0:
		directionFacingRight = false
	$Enemy2AnimatedSprite2D.flip_h = not directionFacingRight

func change_state(new_state: EnemyState2):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
