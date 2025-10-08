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
var death = false   # <-- keep as a property, not shadowed

var HURT2_STREAM: AudioStream = preload("res://Sounds/ZweihanderHurt.wav")
var hurt2_sfx: AudioStreamPlayer2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim = $Enemy2AnimatedSprite2D
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
	invincible_timer = 0.3  # 0.3s of invincibility
	flash_white()  # new function
	if health <= 0 and not death:
		death = true   # <-- fixed (no "var")
		change_state(EnemyDeathState2.new())
	if hurt2_sfx == null:
		hurt2_sfx = AudioStreamPlayer2D.new()
		hurt2_sfx.stream = HURT2_STREAM
		add_child(hurt2_sfx)
	hurt2_sfx.pitch_scale = randf_range(0.95, 1.05)
	hurt2_sfx.volume_db = 0.0   # apply inspector value
	hurt2_sfx.play()

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
		$Enemy2AnimatedSprite2D.flip_h = not directionFacingRight

func flash_white():
	anim.modulate = Color(2, 2, 2, 1)  # red tint
	await get_tree().create_timer(0.1).timeout  # wait 0.1s
	anim.modulate = Color(1, 1, 1)  # back to normal


func change_state(new_state: EnemyState2):
	if state:
		state.exit(self)
	state = new_state
	if state:
		state.enter(self)
