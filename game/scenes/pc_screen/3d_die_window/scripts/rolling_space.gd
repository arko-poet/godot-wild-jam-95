extends Node3D

signal die_result_ready(result: int)

var die_result: int = 0:
	set(value):
		die_result = value
		die_result_ready.emit(value)

var _camera_zoom := false
var _camera_start_transform: Transform3D
var _camera_end_transform: Transform3D
var _transform_perc := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(str(%Die.basis.z))
	#%Die.apply_central_impulse(Vector3(0.0, 0.395107, 0.918635) * 3)
	%Die.result_ready.connect(_on_result_ready)
	%Die.rotate_x(randf_range(0.0, 2.0) * PI)
	%Die.rotate_y(randf_range(0.0, 2.0) * PI)
	%Die.rotate_z(randf_range(0.0, 2.0) * PI)
	%Die.apply_central_impulse(Vector3(0.0, 0.6, 0.6) * 4.5)
	%Die.apply_torque_impulse(Vector3(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0)) * 0.25)

func _process(delta: float) -> void:
	if _camera_zoom:
		_transform_perc = clamp(_transform_perc + (delta * 1.5), 0.0, 1.0) 
		%Camera3D.transform = _camera_start_transform.interpolate_with(_camera_end_transform, _transform_perc)


func _on_result_ready() -> void:
	var result = %Die.get_die_result()
	if result == -1:
		await get_tree().physics_frame
		_on_result_ready()
		return
	die_result = result
	_camera_zoom = true
	%CameraZoomPos.position = %Die.position
	%CameraZoomPos.position.y = 1.25
	%CameraZoomPos.look_at(%Die.position)
	_camera_start_transform = %Camera3D.transform
	_camera_end_transform = %CameraZoomPos.transform
