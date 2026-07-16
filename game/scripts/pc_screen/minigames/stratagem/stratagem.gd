class_name Stratagem extends Minigame

enum _Direction {
	RIGHT,
	DOWN,
	LEFT,
	UP
}

const SPRITE_PATH := "res://game/art/placeholders/stratagem/triangle%s.png"
const _TIME_LIMITS := {
	1: 10.0,
	2: 12.5,
	3: 15.0,
	4: 17.5,
	5: 20.0,
	6: 25
}
const _SEQUENCE_LENGTHS := {
	Difficulty.EASY: 6,
	Difficulty.MEDIUM: 7,
	Difficulty.HARD: 8
}

const _PROGRESS_STEPS := {
	Difficulty.EASY: 0.25,
	Difficulty.MEDIUM: 0.2,
	Difficulty.HARD: 0.15
}
const _PROGRESS_STEP_BACK := 0.1

var _current_sequence: Array[_Direction]
var _sequence_pointer: int

var _progress := 0.0:
	set(value):
		var tween = create_tween()
		tween.tween_property(_progress_bar, ^"value", min(1.0, value), 0.5)
		_progress = min(1.0, value)
		if _progress == 1.0:
			game_won.emit()

@onready var _timer_component: TimerComponent = %TimerComponent
@onready var _arrow_container: HBoxContainer = %ArrowContainer
@onready var _progress_bar: ProgressBar = %ProgressBar


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
	return _TIME_LIMITS.get(dice_roll, _TIME_LIMITS[4])


func _player_action(direction: _Direction) -> void:
	if direction == _current_sequence[_sequence_pointer]:
		_arrow_container.get_children()[_sequence_pointer].modulate = Color.GREEN
		if _sequence_pointer == _current_sequence.size() - 1:
			_sequence_completed()
		else:
			_sequence_pointer += 1
	else:
		_progress -= _PROGRESS_STEP_BACK
		for arrow in _arrow_container.get_children():
			arrow.modulate = Color.WHITE
		_sequence_pointer = 0


func _sequence_completed() -> void:
	_progress += _PROGRESS_STEPS[difficulty]
	
	_set_current_sequence()


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()


func _set_current_sequence() -> void:
	_current_sequence.clear()
	for child in _arrow_container.get_children():
		child.queue_free()
	
	var sequence_length = _SEQUENCE_LENGTHS[difficulty] + (randi() % 3 - 1)
	for i in sequence_length:
		_current_sequence.append(_Direction.values().pick_random())
	print(_current_sequence)
		

	_sequence_pointer = 0
	
	_draw_directions()
	

func _draw_directions() -> void:
	for direction in _current_sequence:
		var arrow := TextureRect.new()
		arrow.texture = load(SPRITE_PATH % direction)
		_arrow_container.add_child(arrow)
