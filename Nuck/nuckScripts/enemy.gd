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
