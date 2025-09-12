extends NuckState
class_name NuckIdleState

@export var patrol_distance := 20  # pixels
@export var patrol_speed := 15      #horizontal speed

var start_position := Vector2.ZERO
var moving_right := true

func enter(nuck):
	print("enter Idle State")
	start_position = nuck.position
	moving_right = true
	if nuck.anim:
		nuck.anim.play("walk")

func physics_update(nuck, delta):
	var offset = nuck.position.x - start_position.x
	
	if moving_right:
		nuck.velocity.x = patrol_speed
		if offset >= patrol_distance:
			moving_right = false
	else:
		nuck.velocity.x = -patrol_speed
		if offset <= 0:
			moving_right = true
	if nuck.player and nuck.position.distance_to(nuck.player.position) < nuck.chase_range:
		nuck.change_state(NuckChaseState.new())
