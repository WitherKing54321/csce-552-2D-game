# PlayerHurtBox.gd
extends Area2D

@export var damage: int = 100           # tweak this to “hit harder”
@export var knockback := Vector2(250, -120)  # optional

func _ready() -> void:
	monitoring = false  # only on during swings

func set_damage(amount: int) -> void:
	damage = amount

func _on_body_entered(body: Node) -> void:
	if not monitoring:
		return
	if body.is_in_group("enemies"):
		if body.has_method("apply_damage"):
			body.apply_damage(damage, global_position, knockback)
		elif "health" in body:
			body.health -= damage
