extends EnemyState
class_name EnemyAttackState

@export var attack_duration := 1.4
@export var damage := 10
@export var hit_start := 0.5  # seconds when the swing begins
@export var hit_end := 0.9    # seconds when the swing ends

var timer := 0.0
var has_hit_player := false

func enter(Enemy):
	Enemy.velocity.x = 10 * Enemy.dir.x
	Enemy.attack = true
	timer = 0.0
	has_hit_player = false
	Enemy.anim.play("nuckAttack")
	# Ensure the hitbox starts disabled
	print("Enemy enters Attack State")

func physics_update(Enemy, delta):
	Enemy.velocity.x = 10 * Enemy.dir.x
	timer += delta
	# end attack after duration
	if timer > attack_duration:
		Enemy.attack = false
		Enemy.change_state(EnemyChaseState.new())
