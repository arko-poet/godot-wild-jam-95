extends ProgressBar


var increasing := true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		if modulate.a >= 0.5 or modulate.a <= 0.0:
			increasing = !increasing
		if increasing:
			modulate.a += 0.005
		else:
			modulate.a -= 0.005
