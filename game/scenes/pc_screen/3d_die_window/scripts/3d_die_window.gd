extends PanelContainer

signal die_result(result: int)
signal menu_hidden
signal menu_shown

var rolling_space = preload("uid://dxo56k8j6eb1f")

var _roll_id := 0

func _ready() -> void:
	hide_menu()

func roll() -> void:
	_roll_id += 1
	var this_roll = _roll_id
	show_menu()
	for _child in %SubViewport.get_children():
		_child.queue_free()
	var _rolling_space = rolling_space.instantiate()
	_rolling_space.die_result_ready.connect(_on_die_result_ready.bind(this_roll))
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

func _on_die_result_ready(result: int, roll_id: int) -> void:
	if roll_id != _roll_id: return # this is so when spamming the reroll button, a new version doesn't show up and then quickly queue frees
	die_result.emit(result)
	await get_tree().create_timer(1.5).timeout
	if roll_id != _roll_id: return
	for _child in %SubViewport.get_children():
		_child.queue_free()
	hide_menu()
