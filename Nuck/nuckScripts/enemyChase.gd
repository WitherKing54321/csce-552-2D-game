extends EnemyState
class_name EnemyChaseState

func enter(Enemy):
		Enemy.anim.play("nuckWalk")
		print("Entered Chase State")

func physics_update(Enemy, delta):
	if not Enemy.player:
		return
	Enemy.dir = (Enemy.player.position - Enemy.position).normalized()
	Enemy.velocity.x = Enemy.dir.x * Enemy.speed

	if Enemy.position.distance_to(Enemy.player.position) < Enemy.attack_range:
		print("ATTTACCCKKK")
		Enemy.change_state(EnemyAttackState.new())
