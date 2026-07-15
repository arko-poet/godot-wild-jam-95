class_name ExampleMinigame extends Minigame

const _REQUIRED_SCORES := {
	Difficulty.EASY: 10,
	Difficulty.MEDIUM: 15,
	Difficulty.HARD: 20
}
const _TIME_LIMITS := {
	1: 1.0,
	2: 1.5,
	3: 2.0,
	4: 2.5,
	5: 3.0,
	6: 3.5
}

var _required_score: int
var _score := 0:
	set(value):
		_score = value
		_update_score_label()
		if _score >= _required_score:
			game_won.emit()
					
@onready var _score_label: Label = %ScoreLabel
@onready var timer_component: TimerComponent = %TimerComponent


func _ready() -> void:
	_required_score = _REQUIRED_SCORES.get(difficulty, _REQUIRED_SCORES[Difficulty.MEDIUM])
	_update_score_label()
	
	timer_component.start_timer(get_time_limit())


func get_time_limit() -> float:
	return _TIME_LIMITS.get(dice_roll, _TIME_LIMITS[4])


func _on_add_score_button_pressed() -> void:
	_score += 1


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()


func _update_score_label() -> void:
	_score_label.text = "Score: %s/%s" % [_score, _required_score]
