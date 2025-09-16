extends EnemyState
class_name EnemyAttackState

@export var attack_duration := 1.4
@export var damage := 25
@export var hit_start := 0.5  # seconds when the swing begins
@export var hit_end := 0.9    # seconds when the swing ends

var timer := 0.0
var has_hit_player := false

func enter(Enemy):
	
	var attack_area = Enemy.get_node("AttackArea")
	attack_area.body_entered.connect(_on_player_enter_hitbox)
	
	Enemy.get_node("AttackArea/CollisionShape2D").disabled = false
	Enemy.velocity.x = 10 * Enemy.dir.x
	Enemy.attack = true
	timer = 0.0
	#has_hit_player = false
	Enemy.anim.play("nuckAttack")
	


func physics_update(Enemy, delta):
	Enemy.dir = (Enemy.player.position - Enemy.position).normalized()
	
	if Enemy.dir.x < 0:
		Enemy.get_node("AttackArea").set_scale(Vector2(1, 1))
	elif Enemy.dir.x > 0: 
		Enemy.get_node("AttackArea").set_scale(Vector2(-1, 1))
		
		
	Enemy.velocity.x = 10 * Enemy.dir.x 
	timer += delta
	# end attack after duration
	if timer > attack_duration:
		Enemy.attack = false
		Enemy.get_node("AttackArea/CollisionShape2D").disabled = true
		Enemy.change_state(EnemyChaseState.new())


func _on_player_enter_hitbox(body):
	if body.is_in_group("player") and not has_hit_player:
		print("Enemy hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
		has_hit_player = true
