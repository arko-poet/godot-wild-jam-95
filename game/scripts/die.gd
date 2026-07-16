extends Sprite2D

signal roll_finished(value: int)

@export var face_textures: Array[Texture2D] = []

var tween: Tween


func roll(final_value: int, length: float = 1.0) -> void:
	if tween and tween.is_valid(): tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	
	# tumbling rotation
	rotation_degrees = randf_range(-25.0, 25.0)
	tween.tween_property(self, "rotation_degrees", 0.0, length).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# random faces with a bunch early and less over time
	var num_swaps := 8
	var land_time := length * 0.8
	for i in num_swaps:
		var time := land_time * ((float(i) / (num_swaps - 1)) ** 2)
		tween.tween_callback(set_face.bind(randi_range(1, 6))).set_delay(time)
	tween.tween_callback(set_face.bind(final_value)).set_delay(land_time)
	
	# squash & stretch when the true face appears
	tween.tween_property(self, "scale", Vector2(1.3, 0.7), length * 0.08)\
		.set_delay(land_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), length * 0.06)\
		.set_delay(land_time + length * 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, length * 0.06)\
		.set_delay(land_time + length * 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func(): roll_finished.emit(final_value)).set_delay(length)


func set_face(value: int) -> void:
	texture = face_textures[value - 1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
