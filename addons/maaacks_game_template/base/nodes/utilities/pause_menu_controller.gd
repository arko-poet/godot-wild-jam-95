extends Node

## Node for opening a pause menu when detecting a 'ui_cancel' event.

@export var pause_menu_packed : PackedScene
@export var focused_viewport : Viewport

var pause_menu : Node

func pause() -> void:
	if pause_menu.visible: return
	var _initial_focus_control := _find_control_focus(get_tree().root)
	
	pause_menu.show()
	if pause_menu is CanvasLayer:
		await pause_menu.visibility_changed
	else:
		await pause_menu.hidden
	if is_inside_tree() and _initial_focus_control:
		_initial_focus_control.grab_focus()

func _find_control_focus(node: Node) -> Control:
	if node is Viewport:
		var focus = node.gui_get_focus_owner()
		if focus: return focus
	for child in node.get_children():
		var child_focus := _find_control_focus(child)
		if child_focus: return child_focus
	return null

# If pause menu should take precedence, override _input() instead.
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause()

func _ready() -> void:
	pause_menu = pause_menu_packed.instantiate()
	pause_menu.hide()
	get_tree().current_scene.call_deferred("add_child", pause_menu)


func _on_pause_button_pressed() -> void:
	pause()
