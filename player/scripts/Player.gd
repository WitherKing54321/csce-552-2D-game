extends CharacterBody2D

# Movement constants
const SPEED := 150.0
const JUMP_VELOCITY := -300.0
const DOUBLE_JUMP_VELOCITY := -400.0
const GRAVITY := 1500.0

# State & combat
var current_state: PlayerState
var has_double_jumped := false
var facing_dir := -1
var max_health := 100
var health := 100

# Death tracking
var deathActive := 0
var _dead := false   # prevents double trigger

@onready var anim = $AnimatedSprite2D

# ------------------ Health / UI ------------------

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

# ------------------ Death flow ------------------

func die():
	if _dead:
		return
	_dead = true
	deathActive += 1
	print("[Player] die() called")

	# enter your death state (plays the death animation/sfx)
	change_state(DeathState.new())

	# small frame to ensure the state/anim starts
	await get_tree().process_frame

	# >>> wait 3 seconds BEFORE pausing or showing the menu <<<
	await get_tree().create_timer(2.0, false).timeout

	# now show the Game Over (this will pause inside the layer)
	_show_game_over()


func _show_game_over() -> void:
	var go = _find_game_over_layer()
	if go:
		print("[Player] Showing Game Over menu")
		go.show_game_over()
	else:
		push_warning("[Player] GameOverLayer not found. Check name/path.")

func _find_game_over_layer() -> Node:
	# 1) Try Unique Name lookup
	var n := get_tree().current_scene.get_node_or_null("%GameOverLayer")
	if n: return n
	# 2) Try absolute path (your root is 'Main' and GO sits directly under it)
	n = get_tree().root.get_node_or_null("Main/GameOverLayer")
	if n: return n
	# 3) Try a relative sibling path just in case
	n = get_tree().current_scene.get_node_or_null("GameOverLayer")
	return n

# ------------------ States ------------------

func hurt():
	change_state(HurtState.new())

func change_state(new_state: PlayerState):
	if current_state:
		current_state.exit(self)
	current_state = new_state
	current_state.enter(self)

# ------------------ Godot callbacks ------------------

func _ready():
	change_state(IdleState.new())
	update_health_bar()

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

# ------------------ Collisions ------------------

func _on_spike_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazards"):
		print("OUCH…spikeys")
		die()   # IMPORTANT: call die(), not just change_state()
