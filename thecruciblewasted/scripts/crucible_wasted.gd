extends CharacterBody2D
class_name Blob  # all instances of Crucible Wasted are 'blob'

@export var speed := 25
@export var attack_range := 20
@export var chase_range := 50
@export var gravity := 800
var health := 100
var player: Node = null
var anim: AnimatedSprite2D
var state: BlobState = null
var attack := false
var directionFacingRight := true
var dir := Vector2.ZERO
var invincible_timer := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim = $AnimatedSprite2D  # updated node reference
	change_state(BlobIdleState.new())

	var hurtbox = get_node("hurtbox")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _on_hurtbox_area_entered(area: Node):
	print("blob feels the blade")
	if area.is_in_group("player_sword") and invincible_timer <= 0:
		take_damage(10)

func take_damage(amount: int):
	print("blob takes damage")
	health -= amount
	invincible_timer = 0.3  # short invulnerability period

	var hurt_state = BlobHurtState.new()
	hurt_state.damage_taken = amount
	change_state(hurt_state)

	if health <= 0:
		change_state(BlobDeathState.new())

func _physics_process(delta):
	invincible_timer -= delta
	if state:
		state.physics_update(self, delta)

	velocity.y += gravity * delta
	move_and_slide()

	# Update facing direction
	if velocity.x < 0:
		directionFacingRight = true
	elif velocity.x > 0:
		directionFacingRight = false

	anim.flip_h = not directionFacingRight

func change_state(new_state: BlobState):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
