extends PlayerState
class_name FightState

var facing_dir := 1
var attack_timer := 0.0

func enter(player):
	var attack_area = player.get_node("AttackArea")#get attack collision shape
	player.get_node("AttackArea/PlayerHurtBox").disabled = false # set diabled by default
	attack_timer = 0.4  # duration of the fight animation
	player.anim.play("fight1")  # use only one animation
	#player.velocity.x = 0  # lock movement during attacks 

func physics_update(player, delta):
	
	if player.facing_dir < 0:
		player.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif player.facing_dir > 0: 
		player.get_node("AttackArea").set_scale(Vector2(-1, 1))
	
	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	facing_dir = input_dir
	player.velocity.x = facing_dir * player.SPEED * 0.3
	
	attack_timer -= delta
	if attack_timer <= 0.0:
		player.get_node("AttackArea/PlayerHurtBox").disabled = false
		if Input.is_action_just_pressed("fight"):
			print("TESSSSTx")
			attack_timer = 0.4
			player.anim.play("fight1")
		else:
			player.get_node("AttackArea/PlayerHurtBox").disabled = true
			_return_to_default(player)

func _return_to_default(player):
	if player.is_on_floor():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			player.change_state(RunState.new())
		else:
			player.change_state(IdleState.new())
	else:
		player.change_state(JumpState.new())
