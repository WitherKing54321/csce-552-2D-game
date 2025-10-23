extends Node

# -------- EDIT ME --------------------------------------------------
const TEST_BGM_PATH := "res://Sounds/vampirewalk.wav"  # your track
# -------------------------------------------------------------------

@export var default_volume_db: float = -6.0        # target volume when inside zone
@export var fade_time: float = 0.6                 # fade seconds
@export var audio_bus: StringName = &"Master"

var _player: AudioStreamPlayer
var _tween: Tween
var _zone_count: int = 0                           # how many MusicZones the player is inside

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player.bus = audio_bus
	_player.autoplay = true
	_player.volume_db = -60.0  # start silent (safe if we spawn outside all zones)
	_player.finished.connect(_on_stream_finished)

	var stream := _load_stream(TEST_BGM_PATH)
	if stream == null:
		push_warning("MusicManager: Could not load: %s" % TEST_BGM_PATH)
		return
	_enable_loop_on_stream(stream)
	_player.stream = stream
	_player.play()  # plays silently until a zone fades us in

# —— Public API called by MusicZone2D ———————————————

func zone_entered() -> void:
	_zone_count += 1
	if not _player.playing:
		_player.play()
	_fade_to(default_volume_db)

func zone_exited() -> void:
	_zone_count = max(0, _zone_count - 1)
	if _zone_count == 0:
		_fade_to(-60.0)  # outside all zones → fade out

# —— Helpers ————————————————————————————————————————

func _load_stream(path: String) -> AudioStream:
	var res := load(path)
	return res if res is AudioStream else null

func _enable_loop_on_stream(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	# others rely on finished->restart

func _on_stream_finished() -> void:
	# safety restart for formats without native loop flags
	if _player.stream:
		_player.play()

func _fade_to(target_db: float) -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", target_db, fade_time)

# Optional: swap tracks later (still zone-aware)
func play_track(path: String) -> void:
	var stream := _load_stream(path)
	if stream == null:
		push_warning("MusicManager: play_track() failed to load: %s" % path)
		return
	_enable_loop_on_stream(stream)
	if _tween: _tween.kill()
	_player.stream = stream
	# keep current zone state: fade to in or out depending on _zone_count
	var target := default_volume_db if _zone_count > 0 else -60.0
	_player.volume_db = target
	if not _player.playing:
		_player.play()
