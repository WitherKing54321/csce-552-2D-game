extends BlobState
class_name BlobIdleState

@export var patrol_distance := 20  # pixels
@export var patrol_speed := 15     # horizontal speed

var start_position := Vector2.ZERO
var moving_right := true

func enter(Blob):
	print("Enter Blob Idle State")
	start_position = Blob.position
	moving_right = true
	if Blob.anim:
		Blob.anim.play("idle")  # adjust animation name as needed

func physics_update(Blob, delta):

	# ====== PATROL LOGIC ======
	var offset = Blob.position.x - start_position.x

	if moving_right:
		Blob.velocity.x = patrol_speed
		if offset >= patrol_distance:
			moving_right = false
	else:
		Blob.velocity.x = -patrol_speed
		if offset <= 0:
			moving_right = true

	# ====== WALK SOUND (patrol loop) ======
	var walk = Blob.get_node_or_null("WalkLoop")
	if Blob.velocity.x != 0.0:
		if walk == null:
			walk = AudioStreamPlayer2D.new()
			walk.name = "WalkLoop"
			walk.stream = preload("res://Sounds/CrucibleWastedChase.wav") # set your path
			Blob.add_child(walk)
		if not walk.playing:
			walk.play()
	else:
		if walk and walk.playing:
			walk.stop()

	# ====== CHASE PLAYER ======
	if Blob.player and Blob.position.distance_to(Blob.player.position) < Blob.chase_range:
		# stop walk loop before switching state
		if walk and walk.playing:
			walk.stop()
		Blob.change_state(BlobChaseState.new())

func exit(Blob):
	var walk = Blob.get_node_or_null("WalkLoop")
	if walk and walk.playing:
		walk.stop()
