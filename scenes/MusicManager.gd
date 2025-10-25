extends Node

# -------- EDIT ME --------------------------------------------------
const TEST_BGM_PATH := "res://Sounds/VampireWalkLong.wav"  # your track
# -------------------------------------------------------------------

@export var default_volume_db: float = -3.0        # volume when inside a zone
@export var fade_time: float = 0.6                 # fade seconds
@export var audio_bus: StringName = &"Master"

var _player: AudioStreamPlayer
var _tween: Tween
var _zone_count: int = 0                           # how many MusicZones the player is inside

# === Mute handling ===
var _is_muted: bool = false
var _desired_db: float = -60.0                     # target loudness ignoring mute

# === Pause tracking (covers both SceneTree pause and time_scale pause) ===
var _was_game_paused: bool = false

func _ready() -> void:
	# Keep running even when the game is paused so we can toggle audio state.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_mute_action()

	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player.bus = audio_bus
	_player.autoplay = true
	_player.volume_db = -60.0  # start silent
	_player.finished.connect(_on_stream_finished)

	var stream := _load_stream(TEST_BGM_PATH)
	if stream == null:
		push_warning("MusicManager: Could not load: %s" % TEST_BGM_PATH)
		return

	_enable_loop_on_stream(stream)
	_player.stream = stream
	_player.play()  # will be silent until a zone fades us in

	# If the game is already paused at startup, apply audio pause immediately.
	_apply_pause_now()

func _process(_delta: float) -> void:
	_update_pause_state()

# —— Public API called by MusicZone2D ———————————————

func zone_entered() -> void:
	_zone_count += 1
	if not _player.playing:
		_player.play()
	_apply_pause_now()  # in case we entered while paused
	_fade_to(default_volume_db)

func zone_exited() -> void:
	_zone_count = max(0, _zone_count - 1)
	if _zone_count == 0:
		_fade_to(-60.0)  # outside all zones → fade out
	else:
		_fade_to(default_volume_db)

# —— Input: Mute toggle ———————————————————————————————

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mute_music"):
		_toggle_mute()

func _toggle_mute() -> void:
	_is_muted = not _is_muted
	if _is_muted:
		if _tween:
			_tween.kill()
		_player.volume_db = -80.0
	else:
		_fade_to(_desired_db)

# —— Helpers ————————————————————————————————————————

func _load_stream(path: String) -> AudioStream:
	var res := load(path)
	return res if res is AudioStream else null

func _enable_loop_on_stream(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	# Others rely on finished->restart as a safety.

func _on_stream_finished() -> void:
	# Only auto-restart if not paused; if paused, stay silent until resume.
	if _player.stream and not _is_game_paused():
		_player.play()

func _fade_to(target_db: float) -> void:
	# Remember intended loudness even while muted.
	_desired_db = target_db

	if _is_muted:
		return

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", target_db, fade_time)

# Optional: swap tracks later (still zone-aware)
func play_track(path: String) -> void:
	var stream := _load_stream(path)
	if stream == null:
		push_warning("MusicManager: play_track() failed to load: %s" % path)
		return

	_enable_loop_on_stream(stream)
	if _tween:
		_tween.kill()

	_player.stream = stream

	var target := default_volume_db if _zone_count > 0 else -60.0
	_desired_db = target

	if not _is_muted:
		_player.volume_db = target

	if not _player.playing:
		_player.play()

	# Respect current pause state after swapping streams.
	_apply_pause_now()

# —— Input setup (runtime convenience) ———————————————

func _setup_mute_action() -> void:
	if not InputMap.has_action("mute_music"):
		InputMap.add_action("mute_music")
		var ev := InputEventKey.new()
		# Use physical key so it's stable across keyboard layouts
		ev.physical_keycode = Key.KEY_M
		InputMap.action_add_event("mute_music", ev)

# —— Pause handling ————————————————————————————————

func _is_game_paused() -> bool:
	# Consider BOTH pause mechanisms:
	# 1) SceneTree pause (get_tree().paused)
	# 2) Global time scaling (Engine.time_scale == 0)
	return get_tree().paused or Engine.time_scale == 0.0

func _apply_pause_now() -> void:
	var paused := _is_game_paused()
	_player.stream_paused = paused

func _update_pause_state() -> void:
	var paused := _is_game_paused()
	if paused == _was_game_paused:
		return
	_was_game_paused = paused
	_player.stream_paused = paused
