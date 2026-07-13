extends Node2D

const Square = preload("uid://bykoixtjlnm5j")

@export_group("Grid Properties")
@export var GRID_WIDTH: int = 13
@export var GRID_HEIGHT: int = 11
@export var CELL_SIZE: int = 64
@export var maze_generator: MazeGenerator


var grid_nodes = []
var wall_positions: Array[Vector2] = []

var start_pos := Vector2(0, 0)
var goal_pos := Vector2(GRID_WIDTH - 1, GRID_HEIGHT - 1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	# RANDOMIZE START AND GOAL POSITIONS HERE (optional)
	wall_positions = maze_generator.generate(GRID_WIDTH, GRID_HEIGHT, start_pos)
	spawn_grid()

func spawn_grid() -> void:
	for row in GRID_HEIGHT:
		grid_nodes.append([])
		for col in GRID_WIDTH:
			var s = Square.instantiate()
			s.position = Vector2(col, row) * CELL_SIZE
			add_child(s)
			if Vector2(col, row) == goal_pos: s.set_type("goal")
			elif wall_positions.has(Vector2(col, row)): s.set_type("wall")
			grid_nodes[row].append(s)

func is_walkable(cell: Vector2) -> bool:
	if cell.x < 0 or cell.x >= GRID_WIDTH or cell.y < 0 or cell.y >= GRID_HEIGHT:
		return false
	return not wall_positions.has(cell)

## Checks to see if path exists from start pos to end pos in an integer grid
func has_path(start: Vector2, end: Vector2, walls: Array) -> bool:
	var queue: Array[Vector2] = [start]
	var visited = {start: true}
	var dirs = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	while not queue.is_empty():
		var cur = queue.pop_front()
		if cur == end: return true
		for d in dirs:
			var next = cur + d
			if (
				next.x < 0 or next.x >= GRID_WIDTH
				or next.y < 0 or next.y >= GRID_HEIGHT
			):
				continue
			
			if visited.has(next) or next in walls: continue
			visited[next] = true
			queue.append(next)
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
