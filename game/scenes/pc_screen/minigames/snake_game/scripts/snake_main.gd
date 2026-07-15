class_name SnakeGame
extends Minigame

const GRID_DIMENSIONS := {
	Difficulty.EASY: {width = 17, height = 13},
	Difficulty.MEDIUM: {width = 17, height = 15},
	Difficulty.HARD: {width = 19, height = 15},
}

const APPLE_TARGETS := {
	Difficulty.EASY: 5,
	Difficulty.MEDIUM: 9,
	Difficulty.HARD: 12
}

const MOVE_INTERVALS := {
	1: 0.12,
	2: 0.14,
	3: 0.16,
	4: 0.18,
	5: 0.20,
	6: 0.22
}

const TIME_LIMITS := { # in seconds
	1: 13,
	2: 15,
	3: 17,
	4: 19,
	5: 21,
	6: 23,
}

const Square = preload("uid://c2r4u5hrhc6qf") # square.tcsn

@export var CELL_SIZE: int = 32
@export var initial_length: int = 3
@onready var move_timer: Timer = %MoveTimer
@onready var timer_component: TimerComponent = %TimerComponent

var grid_width: int
var grid_height: int
var grid_offset := Vector2.ZERO
var grid_nodes = []
var wall_positions: Array[Vector2] = []

var snake_squares: Array[Vector2] = []
var direction := Vector2.RIGHT
var buffered_direction := Vector2.RIGHT
var start_pos := Vector2.ZERO
var apple_pos := Vector2.ZERO
var apple_active := true
var apple_goal_num: int = 0
var num_apples_collected: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_width = GRID_DIMENSIONS.get(difficulty, GRID_DIMENSIONS[Difficulty.MEDIUM]).width
	grid_height = GRID_DIMENSIONS.get(difficulty, GRID_DIMENSIONS[Difficulty.MEDIUM]).height
	apple_goal_num = APPLE_TARGETS.get(difficulty, APPLE_TARGETS[Difficulty.MEDIUM])
	
	start_pos = Vector2(grid_width / 2, grid_height / 2)
	# RANDOMIZE START POSITION / STARTING DIRECTION HERE (optional)
	wall_positions = spawn_border_walls()
	grid_offset = get_grid_offset()
	
	spawn_grid()
	spawn_snake()
	spawn_apple()
	
	move_timer.wait_time = get_move_interval()
	move_timer.start()
	
	print(timer_component)
	timer_component.position = Vector2.DOWN * grid_height * CELL_SIZE + grid_offset
	timer_component.start_timer(get_time_limit())


func spawn_border_walls() -> Array[Vector2]:
	var walls: Array[Vector2] = []
	for col in grid_width:
		walls.append(Vector2(col, 0))
		walls.append(Vector2(col, grid_height - 1))
	for row in range(1, grid_height - 1):
		walls.append(Vector2(0, row))
		walls.append(Vector2(grid_width - 1, row))
	return walls


func spawn_grid() -> void:
	for row in grid_height:
		grid_nodes.append([])
		for col in grid_width:
			var s = Square.instantiate()
			var square_pos = Vector2(col, row)
			s.position = square_pos * CELL_SIZE + grid_offset
			add_child(s)
			if wall_positions.has(square_pos): s.set_type("wall")
			grid_nodes[row].append(s)


func get_square(square: Vector2) -> Node:
	return grid_nodes[int(square.y)][int(square.x)]


func spawn_snake() -> void:
	snake_squares.clear()
	for i in initial_length: snake_squares.append(start_pos - Vector2(i, 0))
	direction = Vector2.RIGHT
	buffered_direction = direction
	draw_snake()


func spawn_apple() -> void:
	if apple_active:
		# randomize apple position, dont spawn in wall
		apple_pos = Vector2(randi_range(1, grid_width - 1), randi_range(1, grid_height - 1))
		get_square(apple_pos).set_type("apple")
		print(apple_pos)
	
	var free_squares: Array[Vector2] = []
	for row in grid_height:
		for col in grid_width:
			var square = Vector2(col, row)
			if is_walkable(square) and not snake_squares.has(square): free_squares.append(square)


func draw_snake() -> void:
	for square in snake_squares: get_square(square).set_type("snake")
	get_square(snake_squares[0]).set_type("snake")


func _unhandled_input(event: InputEvent) -> void:
	var input_dir := Vector2.ZERO
	if event.is_action_pressed("ui_up"): input_dir = Vector2.UP
	if event.is_action_pressed("ui_down"): input_dir = Vector2.DOWN
	if event.is_action_pressed("ui_left"): input_dir = Vector2.LEFT
	if event.is_action_pressed("ui_right"): input_dir = Vector2.RIGHT
	
	if input_dir != Vector2.ZERO and input_dir != -direction:
		buffered_direction = input_dir


func is_walkable(square: Vector2) -> bool:
	if square.x < 0 or square.x >= grid_width or square.y < 0 or square.y >= grid_height:
		return false
	return not wall_positions.has(square)


func get_grid_offset() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var grid_size = Vector2(grid_width, grid_height) * CELL_SIZE
	return ((viewport_size - grid_size) / 2.0).floor()


func get_move_interval() -> float:
	return MOVE_INTERVALS.get(dice_roll, MOVE_INTERVALS[3])


func _on_move_timer_timeout() -> void:
	direction = buffered_direction
	var next_square: Vector2 = snake_squares[0] + direction
	
	if not is_walkable(next_square) or snake_squares.has(next_square):
		move_timer.stop()
		game_lost.emit()
		return
	
	var grew := next_square == apple_pos
	snake_squares.push_front(next_square)
	
	if grew: num_apples_collected += 1
	else:
		var snake_end = snake_squares.pop_back()
		get_square(snake_end).set_type("empty")
	
	draw_snake()
	
	if grew:
		if num_apples_collected >= apple_goal_num:
			move_timer.stop()
			game_won.emit()
			return
		spawn_apple()


func get_time_limit() -> float:
	return TIME_LIMITS.get(dice_roll, TIME_LIMITS[3])


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()
