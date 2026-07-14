extends Minigame

const DIST_BETWEEN_FLOORS = 200.0
const MIN_PLATFORM_OFFSET = 50.0
const MAX_PLATFORM_OFFSET = 200.0

var platform_scene = preload("uid://c4nnus1gtftwt")
var curr_y := 400.0
var layers := 20
var offset_direction := 1.0



func _ready() -> void:
	pass
	#for i in layers:
		#var _platform = platform_scene.instantiate()
		#var _offset_x = 400 + (lerpf(MIN_PLATFORM_OFFSET, MAX_PLATFORM_OFFSET, randf()) * offset_direction)
		#_platform.position = Vector2(_offset_x, curr_y)
		#_platform.player_landed.connect(%Camera2D._on_platform_player_landed)
		#add_child(_platform)
		#curr_y += DIST_BETWEEN_FLOORS
		#offset_direction *= -1.0
	
	#var _platform = platform_scene.instantiate()
	#var _offset_x = 400 + (lerpf(MIN_PLATFORM_OFFSET, MAX_PLATFORM_OFFSET, randf()) * offset_direction)
	#_platform.last_platform = true
	#_platform.position = Vector2(_offset_x, curr_y)
	#_platform.player_landed.connect(%Camera2D._on_platform_player_landed)
	#add_child(_platform)
	
	%TestLabel.text = "dice_roll = %s | difficulty = %s" % [dice_roll, difficulty]
	for _child in %StaticPlatforms.get_children():
		_child.player_landed.connect(%Camera2D._on_platform_player_landed)


func _process(delta: float) -> void:
	%Goal.rotate(PI * delta)
	%TimeLeft.text = str(snapped(%LoseTimer.time_left, 0.1))

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_L):
		print("game_lost signal emitted")
		game_lost.emit()
	if Input.is_key_pressed(KEY_K):
		print("game_won signal emitted")
		game_won.emit()

func _on_kill_plane_body_entered(body: Node2D) -> void:
	assert(false, "something touched the kill plane in rolling game, this should not happen right now")


func _on_goal_body_entered(body: Node2D) -> void:
	if body is RollingPlayer:
		print("game_won signal emitted")
		game_won.emit()

func get_time_limit() -> float:
	return 99

func _on_timer_timeout() -> void:
	game_lost.emit()
