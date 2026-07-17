extends PanelContainer

signal die_result(result: int)
signal menu_hidden
signal menu_shown

var rolling_space = preload("uid://dxo56k8j6eb1f")

func _ready() -> void:
	hide_menu()

func roll() -> void:
	show_menu()
	for _child in %SubViewport.get_children():
		_child.queue_free()
	var _rolling_space = rolling_space.instantiate()
	_rolling_space.die_result_ready.connect(_on_die_result_ready)
	%SubViewport.add_child(_rolling_space)

func show_menu() -> void:
	if !visible:
		show()
		menu_shown.emit()

func hide_menu() -> void:
	if visible:
		for _child in %SubViewport.get_children():
			_child.queue_free()
		hide()
		menu_hidden.emit()

func _on_die_result_ready(result: int) -> void:
	die_result.emit(result)
	await get_tree().create_timer(1.5).timeout
	for _child in %SubViewport.get_children():
		_child.queue_free()
	hide_menu()
