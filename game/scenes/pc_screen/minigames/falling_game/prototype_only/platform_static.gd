extends Node2D

signal player_landed(pos: Vector2)


func _on_player_detector_body_entered(body: Node2D) -> void:
	player_landed.emit(position)
