extends PlayerState
class_name DeathState

var animation_finished := false

func enter(player):
	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if input_dir != 0:
		player.anim.flip_h = input_dir < 0
	player.velocity = Vector2.ZERO   # stop movement
	player.anim.play("death")
	animation_finished = false

	# Connect animation_finished only once
	if not player.anim.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		player.anim.connect("animation_finished", Callable(self, "_on_animation_finished").bind(player))

func physics_update(player, delta):
	# Wait until animation is finished before doing anything
	if animation_finished:
		respawn_or_idle(player)

func _on_animation_finished(anim_name: String, player):
	if anim_name == "death":
		animation_finished = true

func respawn_or_idle(player):
	# Example: reset health
	player.health = player.max_health
	player.update_health_bar()

	# Example: respawn at spawn point (if you have one)
	if player.has_node("/root/Main/SpawnPoint"):
		player.global_position = get_node("/root/Main/SpawnPoint").global_position

	# After respawn, return to idle
	player.change_state(IdleState.new())
