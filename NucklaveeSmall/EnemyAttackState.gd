extends NuckState
class_name NuckAttackState

@export var attack_duration := 1.4
@export var damage := 10
@export var hit_start := 0.5  # seconds when the swing begins
@export var hit_end := 0.9    # seconds when the swing ends

var timer := 0.0
var has_hit_player := false

func enter(nuck):
	nuck.velocity.x = 0
	nuck.attack = true
	timer = 0.0
	has_hit_player = false
	nuck.anim.play("attack")
	# Ensure the hitbox starts disabled
	nuck.attack_hitbox.monitoring = false
	print("Nuck enters Attack State")

func physics_update(nuck, delta):
	timer += delta
	
	# Enable hitbox during swing window
	if timer >= hit_start and timer <= hit_end:
		nuck.attack_hitbox.monitoring = true
	else:
		nuck.attack_hitbox.monitoring = false
	
	# End attack
	if timer >= attack_duration:
		nuck.attack = false
		nuck.attack_hitbox.monitoring = false
		nuck.change_state(NuckChaseState.new())

# Called when the Nuck's attack hitbox overlaps the player
func _on_attack_hit(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Nuck hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
		has_hit_player = true
