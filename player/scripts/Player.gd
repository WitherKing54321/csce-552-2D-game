extends CharacterBody2D

# Movement constants
const SPEED := 150.0
const JUMP_VELOCITY := -300.0
const DOUBLE_JUMP_VELOCITY := -400.0
const GRAVITY := 1500.0

var current_state: PlayerState
var has_double_jumped := false
var facing_dir := -1  # 1 = right, -1 = leftd
var max_health := 100
var health := 100
var deathActive := 0


func die():
	deathActive += 1
	change_state(DeathState.new())
	
func hurt():
	change_state(HurtState.new())

@onready var anim = $AnimatedSprite2D

func update_health_bar():
	var bar = get_node("/root/Main/CanvasLayer/Control/TextureProgressBar")
	bar.max_value = max_health
	bar.value = health

func take_damage(amount):
	health -= amount
	hurt()
	if health <= 0:
		health = 0
		die()
	update_health_bar()

func _ready():
	change_state(IdleState.new())
	update_health_bar()

func change_state(new_state: PlayerState):
	if current_state:
		current_state.exit(self)
	current_state = new_state
	current_state.enter(self)

func _process(delta):
	if current_state:
		current_state.update(self, delta)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if current_state:
		current_state.physics_update(self, delta)
	move_and_slide()

	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if input_dir != 0 and deathActive < 1:
		facing_dir = input_dir
		$AnimatedSprite2D.flip_h = facing_dir > 0

func _on_spike_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazards"):
		print("OUCH…spikeys")
		change_state(DeathState.new())
