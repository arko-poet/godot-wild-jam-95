@abstract
class_name Minigame extends Node

signal game_won


@abstract
func setup() -> void


func _win_game() -> void:
	game_won.emit()
