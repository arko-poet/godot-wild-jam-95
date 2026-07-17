extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("crt_shader")
	visible = CrtShaderController.is_enabled()
	CrtShaderController.crt_filter_changed.connect(func(v): visible = v)
