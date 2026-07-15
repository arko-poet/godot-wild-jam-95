class_name MazeGenerator
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Uses prims algorithm with a frontier to make a maze with short paths and dead ends
func generate(width: int, height: int, start_position: Vector2) -> Array[Vector2]:
	var wall_positions : Array[Vector2] = []
	var open_squares = {}
	var visited_squares = {}
	var stack: Array[Vector2] = []
	var frontier := [] # from: Vector2, wall: vector2,. to: Vector2
	
	visited_squares[start_position] = true
	open_squares[start_position] = true
	stack.push_back(start_position)
	add_frontier(start_position, width, height, visited_squares, frontier)
	
	while not frontier.is_empty():
		var rand_index = randi() % len(frontier)
		var edge = frontier[rand_index]
		frontier.remove_at(rand_index)
		
		if visited_squares.has(edge.to): continue
		
		open_squares[edge.wall] = true
		open_squares[edge.to] = true
		visited_squares[edge.to] = true
		add_frontier(edge.to, width, height, visited_squares, frontier)

	for row in height:
		for col in width:
			if not open_squares.has(Vector2(col, row)):
				wall_positions.append(Vector2(col, row))
	
	return wall_positions

# helper func
func add_frontier(square: Vector2, width: int, height: int, visited_squares: Dictionary, frontier: Array) -> void:
	var dirs = [Vector2.UP * 2, Vector2.DOWN * 2, Vector2.LEFT * 2, Vector2.RIGHT * 2]
	for dir in dirs:
			var new_square = square + dir
			if (
				new_square.x >= 0 and new_square.x < width
				 and new_square.y >= 0 and new_square.y < height
				 and not visited_squares.has(new_square)
			):
				var wall = square + dir / 2
				frontier.append({from = square, wall = wall, to = new_square})
