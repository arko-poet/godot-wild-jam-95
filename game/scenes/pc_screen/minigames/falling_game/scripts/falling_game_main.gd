class_name FallingGame extends Minigame

const TIME_LIMITS = [9223372036854775806, 18, 21, 24, 26, 34, 42] ## time limits given for each dice_value (1-6), index 0 is dummy data
const SPIKE_SURVIVAL_RATES = [0.4, 0.7, 0.9] ## chances that each spike remains active for each difficulty
const LAYERS_PER_DIFF = [8, 11, 14] ## number of layers not counting the first and last, for each difficulty

const DIST_BETWEEN_FLOORS = 150.0 ## pixels to move down after placing a layer
const RIGHT_X_RANGE = [800, 923] ## the lowest and highest values the X position can be on right-side platforms
const MIDDLE_X_RANGE = [441, 623] ## same for middle platforms
const LEFT_X_RANGE = [93, 233] ## same for left-side platforms

var platform_scene = preload("uid://beu0qxq5fklv7")
@onready var curr_y: float = DIST_BETWEEN_FLOORS
var offset_direction := 1.0
var _all_platforms: Array[Node]
var _first_platform_sound := true


func _ready() -> void:
	%TimerComponent.start_timer(TIME_LIMITS[dice_roll])
	
	if !OS.is_debug_build():
		$Prototype.hide()

	
	_add_platform(2, curr_y)
	var _last_side := 2
	for i in LAYERS_PER_DIFF[difficulty]:
		curr_y += DIST_BETWEEN_FLOORS
		var _new_side
		match _last_side:
			0: _new_side = [1, 2].pick_random()
			1: _new_side = [0, 2].pick_random()
			2: _new_side = [0, 1].pick_random()
		_add_platform(_new_side, curr_y)
		_last_side = _new_side
	
	for _platform in %Platforms.get_children():
		_platform.reduce_spikes.call_deferred(SPIKE_SURVIVAL_RATES[difficulty])
	
	curr_y += DIST_BETWEEN_FLOORS
	_add_platform(3, curr_y, true)
	%Goal.position = Vector2(547, curr_y)

#func _process(delta: float) -> void:
	#%Goal.rotate(PI * delta)


func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_L):
			#print("game_lost signal emitted")
			GameplayAudioController.minigame_lost.emit()
			game_lost.emit()
		if Input.is_key_pressed(KEY_K):
			#print("game_won signal emitted")
			GameplayAudioController.minigame_won.emit()
			game_won.emit()

func _on_kill_plane_body_entered(body: Node2D) -> void:
	#print("game_lost signal emitted")
	GameplayAudioController.minigame_lost.emit()
	game_lost.emit()

func _on_timer_component_timeout() -> void:
	#print("game_lost signal emitted")
	GameplayAudioController.minigame_lost.emit()
	game_lost.emit()

func _on_goal_body_entered(body: Node2D) -> void:
	if body is RollingPlayer:
		#print("game_won signal emitted")
		GameplayAudioController.minigame_won.emit()
		game_won.emit()

func get_time_limit() -> float:
	# is now correctly indexed, as dice roll goes from 1 - 6, but index is 0 - 5
	return TIME_LIMITS[dice_roll]

func _add_platform(side:int, y_pos:float, kill_all_spikes := false) -> void:
	var _x_pos: float
	if side == 0:
		_x_pos = lerpf(LEFT_X_RANGE[0], LEFT_X_RANGE[1], randf())
	elif side == 1:
		_x_pos = lerpf(MIDDLE_X_RANGE[0], MIDDLE_X_RANGE[1], randf())
	elif side == 2:
		_x_pos = lerpf(RIGHT_X_RANGE[0], RIGHT_X_RANGE[1], randf())
	elif side == 3:
		_x_pos = 1127.0
	
	var _platform = platform_scene.instantiate()
	_platform.position = Vector2(_x_pos, y_pos)
	_platform.player_landed.connect(%Camera2D._on_platform_player_landed)
	_platform.player_landed.connect(_on_platform_player_landed)
	_all_platforms.append(_platform)
	%Platforms.add_child(_platform)
	
	if kill_all_spikes:
		_platform.reduce_spikes(0.0)

func _on_platform_player_landed(pos: Vector2, me: Node) -> void:
	if _all_platforms.has(me):
		if _first_platform_sound:
			_first_platform_sound = false
		else:
			GameplayAudioController.minigame_good_event.emit()
	_all_platforms.erase(me)
	%PlatformCounter.text = "%s Layers Remaining" % _all_platforms.size()
	
