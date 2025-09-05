extends PlayerState
class_name FightState

var facing_dir := 1
var combo_step := 0
var attack_timer := 0.0

func enter(player):
	combo_step = 1
	set_attack_timer()
	play_attack(player)
	#player.velocity.x = 0  # lock movement during attacks

func play_attack(player):
	match combo_step:
		1: player.anim.play("fight1")
		2: player.anim.play("fight2")
		3: player.anim.play("fight3")

func set_attack_timer():
	match combo_step:
		1: attack_timer = 0.25  # fight1 duration
		2: attack_timer = 0.8  # fight2 duration
		3: attack_timer = 1.0  # fight3 duration

func physics_update(player, delta):
	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	facing_dir = input_dir
	player.velocity.x = facing_dir * player.SPEED * 0.3
	attack_timer -= delta

	if attack_timer <= 0.0:
		if Input.is_action_pressed("fight") and combo_step < 3:
			combo_step += 1
			set_attack_timer()
			play_attack(player)
		else:
			_return_to_default(player)

func _return_to_default(player):
	if player.is_on_floor():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			player.change_state(RunState.new())
		else:
			player.change_state(IdleState.new())
	else:
		player.change_state(JumpState.new())
