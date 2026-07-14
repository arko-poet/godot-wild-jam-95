extends Camera2D

@export var follow_player: CharacterBody2D

var mid_x: float # this will be set to the starting x position

func _ready() -> void:
	mid_x = global_position.x

func _process(delta: float) -> void:
	global_position = Vector2(mid_x, follow_player.global_position.y + 150)
