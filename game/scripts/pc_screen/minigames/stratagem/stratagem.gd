class_name Stratagem extends Minigame

enum _Direction {
	RIGHT,
	DOWN,
	LEFT,
	UP
}

var _current_sequence: Array[_Direction] = [
	_Direction.RIGHT,
	_Direction.DOWN,
	_Direction.LEFT,
	_Direction.UP
]

var _progress := 0.0:
	set(value):
		_progress = value
		if _progress == 1.0:
			game_won.emit()

@onready var _timer_component: TimerComponent = %TimerComponent


func _ready() -> void:
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
	print(direction)


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()
