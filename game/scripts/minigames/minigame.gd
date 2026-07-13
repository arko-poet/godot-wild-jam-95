@abstract
class_name Minigame extends Node

@warning_ignore_start("unused_signal")
signal game_won
signal game_lost

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
}

var difficulty: Difficulty
var dice_roll: int


@abstract
func get_time_limit() -> float
