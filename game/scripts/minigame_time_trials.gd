extends Node

## If this is set to true, it modifies a few components to not lose games
## and instead print out the time it took when the player wins. To see anything
## that checks for this just run Search > Find in Files > MinigameTimeTrials.trials_active
var trials_active := false

## If the trials are active, this will be the minigame you always get. Currently:
## 0 = Falling      1 = Maze      2 = Strategem      3 = Snake
var force_minigame_index := 3

var count_up_timer: Timer

func _ready() -> void:
	if !OS.is_debug_build():
		trials_active = false
	
	count_up_timer = Timer.new()
	count_up_timer.autostart = false
	count_up_timer.one_shot = true
	count_up_timer.wait_time = 999.0
	add_child(count_up_timer)

func start_timer() -> void:
	if count_up_timer.time_left == 0:
		count_up_timer.start()

func stop_timer() -> void:
	if count_up_timer.time_left != 0:
		count_up_timer.stop()

func print_minigame_time() -> void:
	if count_up_timer.time_left == 0:
		print("Minigame time trial result was requested but the timer is not running")
	else:
		print("Minigame results: %ss" % snappedf(999.0 - count_up_timer.time_left, 0.1))
