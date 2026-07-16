extends Node2D

signal game_won

@export var maze: Node2D
@export var move_time: float = 0.15

var grid_pos: Vector2
var is_moving: bool = false
var buffered_dir := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	grid_pos = maze.start_pos
	position = grid_pos * maze.CELL_SIZE + maze.grid_offset


func _process(delta: float) -> void:
	if is_moving: return
	
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_up"): dir = Vector2.UP
	if Input.is_action_pressed("ui_left"): dir = Vector2.LEFT
	if Input.is_action_pressed("ui_down"): dir = Vector2.DOWN
	if Input.is_action_pressed("ui_right"): dir = Vector2.RIGHT
	
	if dir != Vector2.ZERO: try_move(dir)


func try_move(dir: Vector2) -> void:
	var target = grid_pos + dir
	if not maze.is_walkable(target): return
	
	grid_pos = target
	is_moving = true
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", grid_pos * maze.CELL_SIZE + maze.grid_offset, move_time)
	tween.finished.connect(_on_move_finished)

func _on_move_finished() -> void:
	if grid_pos == maze.goal_pos:
		visible = false
		#print("YOU WIN!!!!!!!!!")
		game_won.emit()
	
	is_moving = false

func move_to_start(pos: Vector2) -> void:
	grid_pos = pos
	position = grid_pos * maze.CELL_SIZE + maze.grid_offset
