extends NuckState
class_name NuckAttackState

@export var hop_x := -15
@export var hop_y := -50
@export var attack_duration := 1.4  # seconds
var timer := 0.0

func enter(nuck):
	nuck.attack = true
	print("enter Attack State")
	nuck.anim.play("attack")
	timer = 0.0
	var direction = -1 if nuck.anim.flip_h else 1
	nuck.velocity.x = 0
	
	#nuck.velocity.x = hop_x * direction
	#nuck.velocity.y = hop_y

func physics_update(nuck, delta):
	timer += delta
	if timer >= attack_duration:
		nuck. attack = false
		nuck.change_state(NuckChaseState.new())
