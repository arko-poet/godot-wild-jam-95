extends Camera2D

const MOVE_SPEED = 600.0 ## How fast the camera moves to the next platform
const OFFSET_Y = -200.0 ## how far below the target platform the camera aims for

@onready var target_pos := position

func _process(delta: float) -> void:
	if position.distance_to(target_pos) > (MOVE_SPEED * delta):
		position += position.direction_to(target_pos) * MOVE_SPEED * delta

func _on_platform_player_landed(pos: Vector2) -> void:
	if pos.y + OFFSET_Y > position.y:
		target_pos.y = pos.y + OFFSET_Y
