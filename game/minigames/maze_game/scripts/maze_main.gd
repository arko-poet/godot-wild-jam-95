extends Minigame

const GRID_DIMENSIONS := {
	Difficulty.EASY: {width = 17, height = 13},
	Difficulty.MEDIUM: {width = 17, height = 15},
	Difficulty.HARD: {width = 19, height = 15}
}

const TIME_LIMITS := { # in seconds
	1: 13,
	2: 15,
	3: 17,
	4: 19,
	5: 21,
	6: 23,
}

const Square = preload("uid://bykoixtjlnm5j")

@export var maze_generator: MazeGenerator
@export var player: Node2D
@export var CELL_SIZE: int = 32

@onready var timer_component = %TimerComponent

var grid_width: int;
var grid_height: int
var grid_offset := Vector2.ZERO
var grid_nodes = []
var wall_positions: Array[Vector2] = []
var start_pos := Vector2(0, 0)
var goal_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_width = GRID_DIMENSIONS.get(difficulty, GRID_DIMENSIONS[Difficulty.MEDIUM]).width
	grid_height = GRID_DIMENSIONS.get(difficulty, GRID_DIMENSIONS[Difficulty.MEDIUM]).height
	
	# RANDOMIZE START AND GOAL POSITIONS HERE (optional)
	goal_pos = Vector2(grid_width - 1, grid_height - 1)
	wall_positions = maze_generator.generate(grid_width, grid_height, start_pos)
	grid_offset = get_grid_offset()
	spawn_grid()
	
	player.move_to_start(start_pos)
	player.game_won.connect(func(): game_won.emit())
	
	timer_component.position = Vector2.DOWN* grid_height * CELL_SIZE + grid_offset
	timer_component.start_timer(get_time_limit())


## instantiates all the squares and positons all the squares
func spawn_grid() -> void:
	for row in grid_height:
		grid_nodes.append([])
		for col in grid_width:
			var s = Square.instantiate()
			var square_pos = Vector2(col, row)
			s.position = square_pos * CELL_SIZE + grid_offset
			add_child(s)
			if square_pos == goal_pos: s.set_type("goal")
			elif wall_positions.has(square_pos): s.set_type("wall")
			grid_nodes[row].append(s)


## checks to see if the cell can be walked to
func is_walkable(cell: Vector2) -> bool:
	if cell.x < 0 or cell.x >= grid_width or cell.y < 0 or cell.y >= grid_height:
		return false
	return not wall_positions.has(cell)


func get_grid_offset() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	var grid_size = Vector2(grid_width, grid_height) * CELL_SIZE
	return ((viewport_size - grid_size) / 2.0).floor()


func get_time_limit() -> float:
	return TIME_LIMITS.get(dice_roll, TIME_LIMITS[3])


func _on_timer_component_out_of_time() -> void:
	game_lost.emit()
