extends EnemyState3
class_name EnemyIdleState3

@export var patrol_distance := 20  # pixels
@export var patrol_speed := 15      #horizontal speed

var start_position := Vector2.ZERO
var moving_right := true

func enter(Enemy3):
	print("enter Idle State")
	start_position = Enemy3.position
	moving_right = true
	if Enemy3.anim:
		Enemy3.anim.play("idle")

func physics_update(Enemy3, delta):
	# ====== TEST DAMAGE ======
	if Input.is_action_just_pressed("hurt"):
		var hurt_state = EnemyHurtState3.new()
		hurt_state.damage_taken = 50  # amount of damage for testing
		Enemy3.change_state(hurt_state)
		return  # stop further movement logic this frame

	# ====== PATROL LOGIC ======
	var offset = Enemy3.position.x - start_position.x
	
	if moving_right:
		Enemy3.velocity.x = patrol_speed
		if offset >= patrol_distance:
			moving_right = false
	else:
		Enemy3.velocity.x = -patrol_speed
		if offset <= 0:
			moving_right = true

	# ====== CHASE PLAYER ======
	if Enemy3.player and Enemy3.position.distance_to(Enemy3.player.position) < Enemy3.chase_range:
		Enemy3.change_state(EnemyChaseState3.new())
