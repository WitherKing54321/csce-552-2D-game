extends CharacterBody2D
class_name Nuck

@export var speed := 50
@export var attack_range := 15
@export var chase_range := 50
@export var gravity := 800

@onready var hitbox: = $Hitbox

var health = 100
var player: Node = null
var anim: AnimatedSprite2D
var state: NuckState = null
var attack = false
var directionFacingRight = true


func _ready():
	# Connect the attack hitbox signal
	hitbox.connect("body_entered", Callable(self, "_on_attack_hit"))
	
	player = get_tree().get_first_node_in_group("player")
	anim = $NuckAnimatedSprite2D  # <-- use AnimatedSprite2D
	change_state(NuckIdleState.new())
	#Connect all player swords
	for sword in get_tree().get_nodes_in_group("player_swords"):
		sword.connect("body_entered", Callable(self, "_on_sword_hit"))
	#$Hitbox.connect("body_entered", Callable(self, "_on_Hitbox_body_entered"))

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
	$NuckAnimatedSprite2D.flip_h = not directionFacingRight
	
func _on_sword_hit(body):
	# Check if the collision is with this enemy
	#if body == self:
	print("Ouch! Sword hit me!")
	var hurt_state = NuckHurtState.new()
	hurt_state.damage_taken = 20  # amount of damage for testing
	change_state(hurt_state)
	#return


func change_state(new_state: NuckState):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
