extends Node2D

@export var maze: Node2D
@export var move_time: float = 0.12

var grid_pos: Vector2
var is_moving: bool = false
var buffered_dir := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_pos = maze.start_pos
	position = grid_pos * maze.CELL_SIZE
	z_index = 1 # to put in front of squares, just in case

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	
	var dir := Vector2.ZERO
	if event.is_action_pressed("ui_up"): dir = Vector2.UP
	if event.is_action_pressed("ui_down"): dir = Vector2.DOWN
	if event.is_action_pressed("ui_left"): dir = Vector2.LEFT
	if event.is_action_pressed("ui_right"): dir = Vector2.RIGHT
	
	if dir == Vector2.ZERO: return
	
	if is_moving: buffered_dir = dir
	else: try_move(dir)


func try_move(dir: Vector2) -> void:
	var target = grid_pos + dir
	if not maze.is_walkable(target): return
	
	grid_pos = target
	is_moving = true
	var tween := create_tween()
	tween.tween_property(self, "position", grid_pos * maze.CELL_SIZE, move_time)
	tween.finished.connect(_on_move_finished)

func _on_move_finished() -> void:
	if grid_pos == maze.goal_pos: print("YOU WIN!!!!!!!!!")
	
	is_moving = false
	if buffered_dir != Vector2.ZERO:
		var dir = buffered_dir
		buffered_dir = Vector2.ZERO
		try_move(dir)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
