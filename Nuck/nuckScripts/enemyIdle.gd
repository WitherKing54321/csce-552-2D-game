extends EnemyState
class_name EnemyIdleState

@export var patrol_distance := 20  # pixels
@export var patrol_speed := 15      #horizontal speed

var start_position := Vector2.ZERO
var moving_right := true

func enter(Enemy):
	print("enter Idle State")
	start_position = Enemy.position
	moving_right = true
	if Enemy.anim:
		Enemy.anim.play("nuckWalk")

func physics_update(Enemy, delta):
	# ====== TEST DAMAGE ======
	if Input.is_action_just_pressed("hurt"):
		var hurt_state = EnemyHurtState.new()
		hurt_state.damage_taken = 50  # amount of damage for testing
		Enemy.change_state(hurt_state)
		return  # stop further movement logic this frame

	# ====== PATROL LOGIC ======
	var offset = Enemy.position.x - start_position.x
	
	if moving_right:
		Enemy.velocity.x = patrol_speed
		if offset >= patrol_distance:
			moving_right = false
	else:
		Enemy.velocity.x = -patrol_speed
		if offset <= 0:
			moving_right = true

	# ====== CHASE PLAYER ======
	if Enemy.player and Enemy.position.distance_to(Enemy.player.position) < Enemy.chase_range:
		Enemy.change_state(EnemyChaseState.new())
