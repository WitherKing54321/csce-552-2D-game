extends BlobState
class_name BlobChaseState

@export var damage := 10  # damage dealt to the player

func enter(Blob):
	if Blob.anim:
		Blob.anim.play("idle")
	print("Entered Blob Chase State")

	# Activate attack hitbox
	var attack_area = Blob.get_node("attackarea")
	if not attack_area.body_entered.is_connected(_on_player_enter_hitbox):
		attack_area.body_entered.connect(_on_player_enter_hitbox)

	# Stop any leftover chase loop
	var chase = Blob.get_node_or_null("ChaseLoop")
	if chase and chase.playing:
		chase.stop()

func physics_update(Blob, delta):
	if not Blob.player:
		return

	# Move toward player
	var direction = (Blob.player.position - Blob.position).normalized()
	Blob.velocity.x = direction.x * Blob.speed

	# Flip sprite
	if Blob.velocity.x < 0:
		Blob.directionFacingRight = true
	elif Blob.velocity.x > 0:
		Blob.directionFacingRight = false
	if Blob.anim:
		Blob.anim.flip_h = not Blob.directionFacingRight

	# Optional: attack range check
	if Blob.position.distance_to(Blob.player.position) < Blob.attack_range:
		pass

	# Chase audio (no hit audio)
	var chase = Blob.get_node_or_null("ChaseLoop")
	if Blob.velocity.x != 0.0:
		if chase == null:
			chase = AudioStreamPlayer2D.new()
			chase.name = "ChaseLoop"
			chase.stream = preload("res://Sounds/CrucibleWastedChase.wav") # set your path
			Blob.add_child(chase)
			chase.volume_db = 0.0
		if not chase.playing:
			chase.play()
	else:
		if chase and chase.playing:
			chase.stop()

func _on_player_enter_hitbox(body):
	if body.is_in_group("player"):
		print("Enemy hits the player!")
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)

func exit(Blob):
	# Deactivate attack hitbox
	var attack_area = Blob.get_node("attackarea")
	if attack_area:
		var hitbox = attack_area.get_node("CollisionShape2D")
		if hitbox:
			hitbox.disabled = true

	# Stop chase audio on state change
	var chase = Blob.get_node_or_null("ChaseLoop")
	if chase and chase.playing:
		chase.stop()
