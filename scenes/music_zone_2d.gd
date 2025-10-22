extends Area2D
@export var player_group := "player"

func _ready() -> void:
	monitoring = true
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	# Register if the player starts inside the zone
	call_deferred("_check_initial_overlap")

func _check_initial_overlap() -> void:
	for b in get_overlapping_bodies():
		if b.is_in_group(player_group):
			MusicManager.zone_entered()
			break

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group):
		MusicManager.zone_entered()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(player_group):
		MusicManager.zone_exited()
