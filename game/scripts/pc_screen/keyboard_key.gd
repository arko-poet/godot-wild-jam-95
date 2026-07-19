extends Control

@export var key_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = key_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
