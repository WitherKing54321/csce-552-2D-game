extends Area2D
var damage = 100
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Make sure your player is in this group
		if body.has_method("change_state"):
			var hs = HurtState.new()
			hs.damage_taken = damage
			body.change_state(hs)
