extends BlobState
class_name BlobHurtState

const KNOCKBACK_X := 20
const KNOCKBACK_Y := -70
var damage_taken: int = 0


# --- exported volume (editable in Inspector) ---
@export var hurt_volume_db: float = +5.0  # 0 = normal, negative = quieter, positive = louder

func enter(Blob):
	print("ENTER BLOB HURT STATE")

	# Stop footsteps if they are playing
	if Blob.has_meta("step_sfx"):
		var run_sfx = Blob.get_meta("step_sfx")
		if run_sfx and run_sfx is AudioStreamPlayer2D and run_sfx.playing:
			run_sfx.stop()

	# Apply damage
	Blob.health -= damage_taken
	if Blob.health < 1:
		Blob.health = 0
		Blob.change_state(BlobDeathState.new())
		return

	# Play hurt animation
	if Blob.anim:
		Blob.anim.play("hurt")  # adjust to your Blob hurt animation

	# Knockback direction: opposite of facing
	var direction = -1 if Blob.anim.flip_h else 1
	Blob.velocity.x = KNOCKBACK_X * direction
	Blob.velocity.y = KNOCKBACK_Y

func physics_update(Blob, delta):
	Blob.move_and_slide()

	# Wait until hurt anim is finished
	if not Blob.anim.is_playing() and Blob.health > 0:
		Blob.change_state(BlobIdleState.new())
