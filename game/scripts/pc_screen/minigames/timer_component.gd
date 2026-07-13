class_name TimerComponent extends Label

signal out_of_time

@onready var timer: Timer = %Timer


func _process(_delta: float) -> void:
	if not timer.is_stopped():
		text = "Time Left %.1f.s" % timer.time_left


func start_timer(time: float) -> void:
	timer.start(time)


func _on_timer_timeout() -> void:
	text = "%s" % timer.time_left
	out_of_time.emit()
