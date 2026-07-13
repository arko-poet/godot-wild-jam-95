extends Minigame

const _REQUIRED_SCORE := 10
const _DEFAULT_TIME := 5.0
const _ALLOWED_TIMES = {
	0: 3.0,
	1: 4.0,
	2: 5.0,
	3: 6.0,
	4: 7.0,
	5: 8.0
}

var _score := 0:
	set(value):
		_score = value
		_score_label.text = "Score: %s/%s" % [_score, _REQUIRED_SCORE]
		if _score >= _REQUIRED_SCORE:
			game_won.emit()
					
@onready var _score_label: Label = %ScoreLabel
@onready var timer_component: TimerComponent = %TimerComponent


func _ready() -> void:
	timer_component.start_timer(get_time_limit())


func get_time_limit() -> float:
	return _ALLOWED_TIMES.get(dice_roll, _DEFAULT_TIME)


func _on_add_score_button_pressed() -> void:
	_score += 1


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()
