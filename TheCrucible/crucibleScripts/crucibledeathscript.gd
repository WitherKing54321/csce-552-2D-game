extends BossState
class_name BossDeathState

var timer := 2.3
var done := false

var DEATH_STREAM: AudioStream = preload("res://Sounds/CrucibleDeath.wav")
var death_sfx: AudioStreamPlayer2D

var _boss: Boss  # we'll store a typed ref once in enter()

func enter(b: CharacterBody2D) -> void:
	_boss = b as Boss
	print("Boss begins death sequence")

	# stop any sounds
	for child in _boss.get_children():
		if (child is AudioStreamPlayer or child is AudioStreamPlayer2D) and child.playing:
			child.stop()

	# play death anim + listen for finish (no args in Godot 4)
	if _boss.sprite:
		_boss.sprite.play("death")
		if not _boss.sprite.animation_finished.is_connected(_on_anim_finished):
			_boss.sprite.animation_finished.connect(_on_anim_finished)

	# play death sfx
	if death_sfx == null:
		death_sfx = AudioStreamPlayer2D.new()
		death_sfx.stream = DEATH_STREAM
		death_sfx.volume_db = 0.0
		_boss.add_child(death_sfx)
	death_sfx.play()

	_boss.velocity = Vector2.ZERO

func physics_update(b: CharacterBody2D, delta: float) -> void:
	if _boss == null: 
		return
	_boss.velocity = Vector2.ZERO
	if done:
		return
	timer -= delta
	# Fallback in case the animation never fires
	if timer <= 0.0:
		_finish()

func exit(b: CharacterBody2D) -> void:
	if _boss:
		_boss.velocity = Vector2.ZERO
		if _boss.sprite and _boss.sprite.animation_finished.is_connected(_on_anim_finished):
			_boss.sprite.animation_finished.disconnect(_on_anim_finished)

# --- signal handlers / helpers ---

func _on_anim_finished() -> void:
	if _boss and _boss.sprite and _boss.sprite.animation == "death" and not done:
		_finish()

func _finish() -> void:
	done = true
	if _boss:
		_boss.die()  # <-- emits boss_defeated, FogWall opens
