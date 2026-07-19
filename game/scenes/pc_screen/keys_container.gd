extends VBoxContainer

@export var key_groups: Array = [] # Array[Array[Control]]
var total_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	if int(total_time) % 4 < 2:
		
		for key in key_groups[0]: get_node(key).show()
		for key in key_groups[1]: get_node(key).hide()
	else:
		for key in key_groups[0]: get_node(key).hide()
		for key in key_groups[1]: get_node(key).show()
