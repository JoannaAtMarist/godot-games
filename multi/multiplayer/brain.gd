extends Area2D

const POINTS := 1


func _on_body_entered(body: Node2D) -> void:
	# Clients simulate the overlap too. Only the server may award points.
	if not multiplayer.is_server():
		return
	if not body.is_in_group("players"):
		return
	MultiplayerManager.award_pickup(body.player_id, get_path(), POINTS)
