extends CharacterBody2D
class_name Enemy

@export var speed := 50
@export var attack_range := 20
@export var chase_range := 50
@export var gravity := 800

var health = 100
var player: Node = null
var anim: AnimatedSprite2D
var state: EnemyState = null
var attack = false
var directionFacingRight = true
var dir = 0


func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim = $nuckAnimated  # <-- use AnimatedSprite2D
	change_state(EnemyIdleState.new())
	
	var hurtbox = get_node("hurtbox")
	hurtbox.area_entered.connect(_on_hurtbox_body_entered)
	
	#attack_area.body_entered.connect(_on_player_enter_hitbox)
	
func _on_hurtbox_body_entered(area: Node):
	print("nuck feels the blade")
	if area.is_in_group("player_sword"):  # e.g. sword hitbox
		take_damage(10)
		
func take_damage(amount: int):
	print("nuck takes damage")
	var hurt_state = EnemyHurtState.new()
	hurt_state.damage_taken = 10
	change_state(hurt_state)
	if health <= 0:
		change_state(EnemyDeathState.new())  # enemy dies


func _physics_process(delta):
	if state:
		state.physics_update(self, delta)
	velocity.y += gravity * delta
	move_and_slide()
	# Update facing direction based on X velocity
	if velocity.x < 0:
		directionFacingRight = true
	elif velocity.x > 0:
		directionFacingRight = false
	$nuckAnimated.flip_h = not directionFacingRight

func change_state(new_state: EnemyState):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
