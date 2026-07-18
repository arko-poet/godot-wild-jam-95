extends RigidBody3D

signal result_ready()

var is_moving := true
var die_result: int

@onready var _last_pos := global_position
var _delta_since_moved := 0.0


func _physics_process(delta: float) -> void:
	#print("%s %s" % [global_position.distance_to(_last_pos), _delta_since_moved])
	if is_moving:
		if global_position.distance_to(_last_pos) <= 0.01:
			_delta_since_moved += delta
			if _delta_since_moved >= 0.75:
				is_moving = false
				result_ready.emit()
		_last_pos = global_position

## Returns 1-6 if the die isn't moving and is ready to provide results, otherwise
## returns a 0
func get_die_result() -> int:
	var _output: Array[int]
	if is_moving:
		return 0
	if %One.is_colliding():
		_output.append(1)
	if %Two.is_colliding():
		_output.append(2)
	if %Three.is_colliding():
		_output.append(3)
	if %Four.is_colliding():
		_output.append(4)
	if %Five.is_colliding():
		_output.append(5)
	if %Six.is_colliding():
		_output.append(6)
	if _output.size() != 1: return -1
	assert(_output.size() == 1, "_output.size in get_die_result() is: %s" % _output.size())
	if _output.size() == 0:
		return 0
	else:
		return _output[0]
