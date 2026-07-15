extends Minigame

enum Direction {
	RIGHT,
	DOWN,
	LEFT,
	UP
}

var current_sequence: Array[Direction] = [
	Direction.RIGHT,
	Direction.DOWN,
	Direction.LEFT,
	Direction.UP
]


@onready var timer_component: TimerComponent = %TimerComponent


func _ready() -> void:
	timer_component.start_timer(get_time_limit())


func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action(&"ui_right"):
		_player_action(Direction.RIGHT)
	elif event.is_action(&"ui_down"):
		_player_action(Direction.DOWN)
	elif event.is_action(&"ui_left"):
		_player_action(Direction.LEFT)
	elif event.is_action(&"ui_up"):
		_player_action(Direction.UP)
	else:
		return
	
	get_viewport().set_input_as_handled()


func get_time_limit() -> float:
	return 100.0


func _player_action(direction: Direction) -> void:
	print(direction)
