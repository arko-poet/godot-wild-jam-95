extends Minigame

const _REQUIRED_SCORE := 10
const _DEFAULT_TIME := 30.0
const _ALLOWED_TIMES = {
	0: 10.0,
	1: 15.0,
	2: 20.0,
	3: 25.0,
	4: 30.0,
	5: 35.0
}

var _score := 0:
	set(value):
		_score = value
		_score_label.text = "Score: %s/%s" % [_score, _REQUIRED_SCORE]
		if _score >= _REQUIRED_SCORE:
			game_won.emit()
					
@onready var _score_label: Label = %ScoreLabel


func get_time_limit() -> float:
	return _ALLOWED_TIMES.get(dice_roll, _DEFAULT_TIME)
			


func _on_add_score_button_pressed() -> void:
	_score += 1
