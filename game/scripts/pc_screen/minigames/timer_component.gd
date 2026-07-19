class_name TimerComponent extends Label

signal out_of_time

@onready var timer: Timer = %Timer


func _process(_delta: float) -> void:
	if not timer.is_stopped():
		text = "Time Left %.1f.s" % snappedf(timer.time_left, 0.1)


func start_timer(time: float) -> void:
	if MinigameTimeTrials.trials_active: return
	timer.start(time)


func _on_timer_timeout() -> void:
	text = "%s" % snappedf(timer.time_left, 0.1)
	out_of_time.emit()
