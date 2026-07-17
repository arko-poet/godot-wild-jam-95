extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DieWindow3D.menu_hidden.connect(_on_menu_hidden)
	$DieWindow3D.menu_shown.connect(_on_menu_shown)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_menu_shown() -> void:
	$RollButton.disabled = true

func _on_menu_hidden() -> void:
	$RollButton.disabled = false

func _on_roll_button_pressed() -> void:
	$DieWindow3D.roll()

func _on_d_die_window_die_result(result: int) -> void:
	$Label.text = "Result: %s" % result
