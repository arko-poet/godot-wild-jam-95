extends Minigame

@onready var timer_component: TimerComponent = %TimerComponent


func _ready() -> void:
	timer_component.start_timer(get_time_limit())


func get_time_limit() -> float:
	return 100.0
