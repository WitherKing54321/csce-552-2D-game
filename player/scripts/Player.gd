extends CharacterBody2D

const SPEED := 150.0
const JUMP_VELOCITY := -300.0
const DOUBLE_JUMP_VELOCITY := -400.0
const GRAVITY := 1500.0

var current_state: PlayerState
var has_double_jumped := false
var facing_dir := 1  # 1 = right, -1 = leftd


@onready var anim = $AnimatedSprite2D

func _ready():
	change_state(IdleState.new())

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
	if input_dir != 0:
		facing_dir = input_dir
		$AnimatedSprite2D.flip_h = facing_dir > 0
