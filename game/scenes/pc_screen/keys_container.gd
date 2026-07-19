extends VBoxContainer

@export var key_groups: Array = [] # Array[Array[Control]]
var total_time = 0.0

var tween_timeout = 5.0
var starting_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = position

func show_controls() -> void:
	visible = true
	modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_interval(tween_timeout)
	tween.tween_property(self, "modulate", Color(0,0,0,0), tween_timeout / 2.0)
	tween.tween_callback(func(): visible = false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	if int(total_time) % 4 < 2:
		
		for key in key_groups[0]: get_node(key).show()
		for key in key_groups[1]: get_node(key).hide()
	else:
		for key in key_groups[0]: get_node(key).hide()
		for key in key_groups[1]: get_node(key).show()
	print(global_position, position)
