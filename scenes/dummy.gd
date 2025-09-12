# Dummy.gd
extends StaticBody2D
class_name Dummy

@export var health := 100  # Dummy HP
@onready var hurtbox: Area2D = $Hurtbox  # Make sure this is the Area2D

func _ready():
	# Connect the hurtbox signal to detect collisions with swords
	hurtbox.connect("body_entered", Callable(self, "_on_hurtbox_body_entered"))

func _on_hurtbox_body_entered(body):
	# Only take damage if the colliding body is a sword (or in a "player_swords" group)
	if body.is_in_group("player_swords"):
		take_damage(10)  # Example damage
		print("Dummy hit! Health:", health)

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		health = 0
		print("Dummy destroyed!")
		queue_free()  # Optional: remove dummy from scene
