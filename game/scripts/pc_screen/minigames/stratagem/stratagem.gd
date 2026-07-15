class_name Stratagem extends Minigame

enum _Direction {
	RIGHT,
	DOWN,
	LEFT,
	UP
}

const _SEQUENCE_LENGTHS := {
	Difficulty.EASY: 5,
	Difficulty.MEDIUM: 6,
	Difficulty.HARD: 7
}

const _PROGRESS_STEPS := {
	Difficulty.EASY: 0.25,
	Difficulty.MEDIUM: 0.2,
	Difficulty.HARD: 0.15
}

var _current_sequence: Array[_Direction]
var _sequence_pointer: int

var _progress := 0.0:
	set(value):
		_progress = max(1.0, value)
		if _progress == 1.0:
			game_won.emit()

@onready var _timer_component: TimerComponent = %TimerComponent


func _ready() -> void:
	_set_current_sequence()
	_timer_component.start_timer(get_time_limit())


func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
		
	var direction: _Direction
	if event.is_action(&"ui_right"):
		direction = _Direction.RIGHT
	elif event.is_action(&"ui_down"):
		direction = _Direction.DOWN
	elif event.is_action(&"ui_left"):
		direction = _Direction.LEFT
	elif event.is_action(&"ui_up"):
		direction = _Direction.UP
	else:
		return
	
	get_viewport().set_input_as_handled()
	
	_player_action(direction)


func get_time_limit() -> float:
	return 100.0


func _player_action(direction: _Direction) -> void:
	if direction != _current_sequence[_sequence_pointer]:
		print("MATCH")
		if _sequence_pointer == _current_sequence.size() - 1:
			_sequence_completed()
		else:
			_sequence_pointer += 1
	else:
		print("MISMATCH")
		_sequence_pointer = 0


func _sequence_completed() -> void:
	_progress += _PROGRESS_STEPS[difficulty]
	
	_set_current_sequence()


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()


func _set_current_sequence() -> void:
	_current_sequence.clear()
	
	var sequence_length = _SEQUENCE_LENGTHS[difficulty] + (randi() % 3 - 1)
	for i in sequence_length:
		_current_sequence.append(_Direction.values().pick_random())
		
	_sequence_pointer = 0
