extends PlayerState
class_name DeathState

const DEATH_SFX: AudioStream = preload("res://Sounds/Jump.wav")
var _death_player: AudioStreamPlayer
var animation_finished := false

func enter(player):
	# --- play death sfx once ---
	if _death_player == null:
		_death_player = AudioStreamPlayer.new()
		_death_player.autoplay = false
		# _death_player.bus = "SFX"  # (optional) route to your SFX bus
		player.add_child(_death_player)
	_death_player.stream = DEATH_SFX
	_death_player.play()
	# ---------------------------
	player.deathActive = 1
	var input_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if input_dir != 0:
		player.anim.flip_h = input_dir < 0
	player.velocity = Vector2.ZERO
	player.anim.play("death")
	animation_finished = false

	if not player.anim.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		player.anim.connect("animation_finished", Callable(self, "_on_animation_finished").bind(player))

func physics_update(player, delta):
	if animation_finished:
		respawn_or_idle(player)

func _on_animation_finished(anim_name: String, player):
	if anim_name == "death":
		animation_finished = true

func respawn_or_idle(player):
	player.health = player.max_health
	player.update_health_bar()

	if player.has_node("/root/Main/SpawnPoint"):
		player.global_position = get_node("/root/Main/SpawnPoint").global_position

	player.change_state(IdleState.new())
