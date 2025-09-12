extends CharacterBody2D
class_name Nuck

@export var speed := 50
@export var attack_range := 15
@export var chase_range := 50
@export var gravity := 800

@onready var hitbox: Area2D = $Hitbox

var player: Node = null
var anim: AnimatedSprite2D
var state: NuckState = null
var attack = false
var directionFacingRight = true


func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim = $NuckAnimatedSprite2D  # <-- use AnimatedSprite2D
	change_state(NuckIdleState.new())
	$Hitbox.connect("body_entered", Callable(self, "_on_Hitbox_body_entered"))
	
func _on_Hitbox_body_entered(body):
	if body.is_in_group("player"):
		var hs = HurtState.new()
		hs.damage_taken = 50   # assign damage value
		player.change_state(hs)
 


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
	

func change_state(new_state: NuckState):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
