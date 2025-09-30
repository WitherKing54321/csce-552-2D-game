extends EnemyState2
class_name EnemyIdleState2

@export var patrol_distance := 20  # pixels
@export var patrol_speed := 15      #horizontal speed

var start_position := Vector2.ZERO
var moving_right := true

func enter(Enemy2):
	print("enter Idle State")
	start_position = Enemy2.position
	moving_right = true
	if Enemy2.anim:
		Enemy2.anim.play("enemy2Walk")

func physics_update(Enemy2, delta):
	# ====== TEST DAMAGE ======
	if Input.is_action_just_pressed("hurt"):
		var hurt_state = EnemyHurtState2.new()
		hurt_state.damage_taken = 50  # amount of damage for testing
		Enemy2.change_state(hurt_state)
		return  # stop further movement logic this frame

	# ====== PATROL LOGIC ======
	var offset = Enemy2.position.x - start_position.x
	
	if moving_right:
		Enemy2.velocity.x = patrol_speed
		if offset >= patrol_distance:
			moving_right = false
	else:
		Enemy2.velocity.x = -patrol_speed
		if offset <= 0:
			moving_right = true

	# ====== CHASE PLAYER ======
	if Enemy2.player and Enemy2.position.distance_to(Enemy2.player.position) < Enemy2.chase_range:
		Enemy2.change_state(EnemyChaseState2.new())
