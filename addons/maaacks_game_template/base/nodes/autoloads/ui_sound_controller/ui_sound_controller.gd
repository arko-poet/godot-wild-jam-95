class_name UISoundController
extends Node
## Controller for managing all UI sounds in a scene from one place.
##
## This node manages all of the UI sounds under the provided node path.
## When attached just below the root node of a scene tree, it will manage
## all of the UI sounds in that scene.

const MAX_DEPTH = 16

@export var root_path : NodePath = ^".."
## Audio bus for any audio streams created.
@export var audio_bus : StringName = &"SFX"
## Continually check any new nodes added to the scene tree.
@export var persistent : bool = true :
	set(value):
		persistent = value
		_update_persistent_signals()

@export_group("Button Sounds")
@export var button_hovered : AudioStream
@export var button_focused : AudioStream
@export var button_pressed : Array[AudioStream] = []

@export_group("TabBar Sounds")
@export var tab_hovered : AudioStream
@export var tab_changed : AudioStream
@export var tab_selected : AudioStream

@export_group("Slider Sounds")
@export var slider_hovered : AudioStream
@export var slider_focused : AudioStream
@export var slider_drag_started : AudioStream
@export var slider_drag_ended : AudioStream

@export_group("LineEdit Sounds")
@export var line_hovered : AudioStream
@export var line_focused : AudioStream
@export var line_text_changed : AudioStream
@export var line_text_submitted : AudioStream
@export var line_text_change_rejected : AudioStream

@export_group("ItemList Sounds")
@export var item_list_selected : AudioStream
@export var item_list_activated : AudioStream

@export_group("Tree Sounds")
@export var tree_item_selected : AudioStream
@export var tree_item_activated : AudioStream
@export var tree_button_clicked : AudioStream

@export_group("Minigame Sounds")
@export var minigame_won: Array[AudioStream] = []
@export var minigame_lost: Array[AudioStream] = []
@export var minigame_good_event: Array[AudioStream] = []
@export var minigame_bad_event: Array[AudioStream] = []
@export var minigame_progress: Array[AudioStream] = []
@export var dice_roll: Array[AudioStream] = []
@export var entity_step: Array[AudioStream] = []

@onready var root_node : Node = get_node(root_path)

var button_hovered_player : AudioStreamPlayer
var button_focused_player : AudioStreamPlayer
var button_pressed_player : AudioStreamPlayer

var tab_hovered_player : AudioStreamPlayer
var tab_changed_player : AudioStreamPlayer
var tab_selected_player : AudioStreamPlayer

var slider_hovered_player : AudioStreamPlayer
var slider_focused_player : AudioStreamPlayer
var slider_drag_started_player : AudioStreamPlayer
var slider_drag_ended_player : AudioStreamPlayer

var line_hovered_player : AudioStreamPlayer
var line_focused_player : AudioStreamPlayer
var line_text_changed_player : AudioStreamPlayer
var line_text_submitted_player : AudioStreamPlayer
var line_text_change_rejected_player : AudioStreamPlayer

var item_list_activated_player : AudioStreamPlayer
var item_list_selected_player : AudioStreamPlayer

var tree_item_activated_player : AudioStreamPlayer
var tree_item_selected_player : AudioStreamPlayer
var tree_button_clicked_player : AudioStreamPlayer

var minigame_won_player: AudioStreamPlayer
var minigame_lost_player: AudioStreamPlayer
var minigame_good_event_player: AudioStreamPlayer
var minigame_bad_event_player: AudioStreamPlayer
var minigame_progress_player: AudioStreamPlayer
var dice_roll_player: AudioStreamPlayer
var entity_step_player: AudioStreamPlayer

func _update_persistent_signals() -> void:
	if not is_inside_tree():
		return
	var tree_node = get_tree()
	if persistent:
		if not tree_node.node_added.is_connected(connect_ui_sounds):
			tree_node.node_added.connect(connect_ui_sounds)
	else:
		if tree_node.node_added.is_connected(connect_ui_sounds):
			tree_node.node_added.disconnect(connect_ui_sounds)

# This is only for minigames
func _first_stream(streams: Array[AudioStream]) -> AudioStream:
	return streams[0] if not streams.is_empty() else null

func _build_stream_player(stream : AudioStream, stream_name : String = "") -> AudioStreamPlayer:
	var stream_player : AudioStreamPlayer
	if stream != null:
		stream_player = AudioStreamPlayer.new()
		stream_player.stream = stream
		stream_player.bus = audio_bus
		stream_player.name = stream_name + "AudioStreamPlayer"
		add_child(stream_player)
	return stream_player

func _build_button_stream_players() -> void:
	button_hovered_player = _build_stream_player(button_hovered, "ButtonHovered")
	button_focused_player = _build_stream_player(button_focused, "ButtonFocused")
	button_pressed_player = _build_stream_player(_first_stream(button_pressed), "ButtonClicked")

func _build_tab_stream_players() -> void:
	tab_hovered_player = _build_stream_player(tab_hovered, "TabHovered")
	tab_changed_player = _build_stream_player(tab_changed, "TabChanged")
	tab_selected_player = _build_stream_player(tab_selected, "TabSelected")

func _build_slider_stream_players() -> void:
	slider_hovered_player = _build_stream_player(slider_hovered, "SliderHovered")
	slider_focused_player = _build_stream_player(slider_focused, "SliderFocused")
	slider_drag_started_player = _build_stream_player(slider_drag_started, "SliderDragStarted")
	slider_drag_ended_player = _build_stream_player(slider_drag_ended, "SliderDragEnded")

func _build_line_stream_players() -> void:
	line_hovered_player = _build_stream_player(line_hovered, "LineHovered")
	line_focused_player = _build_stream_player(line_focused, "LineFocused")
	line_text_changed_player = _build_stream_player(line_text_changed, "LineTextChanged")
	line_text_submitted_player = _build_stream_player(line_text_submitted, "LineTextSubmitted")
	line_text_change_rejected_player = _build_stream_player(line_text_change_rejected, "LineTextChangeRejected")

func _build_item_list_stream_players() -> void:
	item_list_activated_player = _build_stream_player(item_list_activated, "ItemActivated")
	item_list_selected_player = _build_stream_player(item_list_selected, "ItemSelected")

func _build_tree_stream_players() -> void:
	tree_item_activated_player = _build_stream_player(tree_item_activated, "TreeItemActivated")
	tree_item_selected_player = _build_stream_player(tree_item_selected, "TreeItemSelected")
	tree_button_clicked_player = _build_stream_player(tree_button_clicked, "TreeButtonClicked")

func _build_minigame_stream_players() -> void:
	minigame_won_player = _build_stream_player(_first_stream(minigame_won), "MinigameWon")
	minigame_lost_player = _build_stream_player(_first_stream(minigame_lost), "MinigameLost")
	minigame_good_event_player = _build_stream_player(_first_stream(minigame_good_event), "MinigameGoodEvent")
	minigame_bad_event_player = _build_stream_player(_first_stream(minigame_bad_event), "MinigameBadEvent")
	minigame_progress_player = _build_stream_player(_first_stream(minigame_progress), "MinigameProgress")
	
	dice_roll_player = _build_stream_player(_first_stream(dice_roll), "DiceRoll")
	entity_step_player = _build_stream_player(_first_stream(entity_step), "EntityStep")
	if entity_step_player:
		entity_step_player.volume_db += 10.0


func _build_all_stream_players() -> void:
	_build_button_stream_players()
	_build_tab_stream_players()
	_build_slider_stream_players()
	_build_line_stream_players()
	_build_item_list_stream_players()
	_build_tree_stream_players()
	_build_minigame_stream_players()

func _play_stream(stream_player : AudioStreamPlayer) -> void:
	if not stream_player.is_inside_tree():
		return
	stream_player.play()

# This is only for minigames
func _play_indexed_stream(sfx_index: int, streams: Array[AudioStream], stream_player: AudioStreamPlayer) -> void:
	if stream_player == null or streams.is_empty(): return
	if not stream_player.is_inside_tree(): return
	var index := clampi(sfx_index, 0, len(streams) - 1)
	stream_player.stream = streams[index]
	stream_player.play() 

func _button_pressed_play_stream(button_node: Node, stream_player: AudioStreamPlayer) -> void:
	var index: int = 0
	
	if button_node.has_meta("sfx_index"):
		index = button_node.get_meta("sfx_index")
	
	_play_indexed_stream(index, button_pressed, stream_player)

func _tab_event_play_stream(_tab_idx : int, stream_player : AudioStreamPlayer) -> void:
	_play_stream(stream_player)

func _slider_drag_ended_play_stream(_value_changed : bool, stream_player : AudioStreamPlayer) -> void:
	_play_stream(stream_player)

func _line_event_play_stream(_new_text : String, stream_player : AudioStreamPlayer) -> void:
	_play_stream(stream_player)

func _item_list_play_stream(_index : int, stream_player : AudioStreamPlayer) -> void:
	_play_stream(stream_player)

func _tree_button_clicked_play_stream(_tree_item : TreeItem, _column : int, _id : int, _mouse_button_index : int, stream_player : AudioStreamPlayer) -> void:
	_play_stream(stream_player)

func _connect_stream_player(node : Node, stream_player : AudioStreamPlayer, signal_name : StringName, callable : Callable) -> void:
	if stream_player != null and not node.is_connected(signal_name, callable.bind(stream_player)):
		node.connect(signal_name, callable.bind(stream_player))

func connect_ui_sounds(node: Node) -> void:
	if node is Button:
		_connect_stream_player(node, button_hovered_player, &"mouse_entered", _play_stream)
		_connect_stream_player(node, button_focused_player, &"focus_entered", _play_stream)
		if button_pressed_player != null and not node.pressed.is_connected(_button_pressed_play_stream):
			node.pressed.connect(_button_pressed_play_stream.bind(node, button_pressed_player))
		#_connect_stream_player(node, button_pressed_player, &"pressed", _play_stream)
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif node is TabBar:
		_connect_stream_player(node, tab_hovered_player, &"tab_hovered", _tab_event_play_stream)
		_connect_stream_player(node, tab_changed_player, &"tab_changed", _tab_event_play_stream)
		_connect_stream_player(node, tab_selected_player, &"tab_selected", _tab_event_play_stream)
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif node is Slider:
		_connect_stream_player(node, slider_hovered_player, &"mouse_entered", _play_stream)
		_connect_stream_player(node, slider_focused_player, &"focus_entered", _play_stream)
		_connect_stream_player(node, slider_drag_started_player, &"drag_started", _play_stream)
		_connect_stream_player(node, slider_drag_ended_player, &"drag_ended", _slider_drag_ended_play_stream)
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif node is LineEdit:
		_connect_stream_player(node, line_hovered_player, &"mouse_entered", _play_stream)
		_connect_stream_player(node, line_focused_player, &"focus_entered", _play_stream)
		_connect_stream_player(node, line_text_changed_player, &"text_changed", _line_event_play_stream)
		_connect_stream_player(node, line_text_submitted_player, &"text_submitted", _line_event_play_stream)
		_connect_stream_player(node, line_text_change_rejected_player, &"text_change_rejected", _line_event_play_stream)
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif node is ItemList:
		_connect_stream_player(node, item_list_activated_player, &"item_activated", _item_list_play_stream)
		_connect_stream_player(node, item_list_selected_player, &"item_selected", _item_list_play_stream)
	elif node is Tree:
		_connect_stream_player(node, tree_item_activated_player, &"item_activated", _play_stream)
		_connect_stream_player(node, tree_item_selected_player, &"item_selected", _play_stream)
		_connect_stream_player(node, tree_button_clicked_player, &"button_clicked", _tree_button_clicked_play_stream)

func _recursive_connect_ui_sounds(current_node: Node, current_depth : int = 0) -> void:
	if current_depth >= MAX_DEPTH:
		return
	for node in current_node.get_children():
		connect_ui_sounds(node)
		_recursive_connect_ui_sounds(node, current_depth + 1)

func play_minigame_won(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, minigame_won, minigame_won_player)

func play_minigame_lost(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, minigame_lost, minigame_lost_player)

func play_minigame_good_event(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, minigame_good_event, minigame_good_event_player)

func play_minigame_bad_event(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, minigame_bad_event, minigame_bad_event_player)

func play_minigame_progress(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, minigame_progress, minigame_progress_player)

func play_dice_roll(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, dice_roll, dice_roll_player)
	
func play_entity_step(sfx_index: int = 0) -> void:
	_play_indexed_stream(sfx_index, entity_step, entity_step_player)

func _minigame_bus_connections() -> Dictionary:
	return {
		GameplayAudioController.minigame_won : play_minigame_won,
		GameplayAudioController.minigame_lost : play_minigame_lost,
		GameplayAudioController.minigame_good_event : play_minigame_good_event,
		GameplayAudioController.minigame_bad_event : play_minigame_bad_event,
		GameplayAudioController.minigame_progress : play_minigame_progress,
		GameplayAudioController.dice_roll : play_dice_roll,
		GameplayAudioController.entity_step : play_entity_step,
	}

func _connect_minigame_bus() -> void:
	var connections := _minigame_bus_connections()
	for key in connections:
		var function_to_call: Callable = connections[key]
		if not key.is_connected(function_to_call):
			key.connect(function_to_call)

func _disconnect_minigame_bus() -> void:
	var connections := _minigame_bus_connections()
	for key in connections:
		var function_to_call: Callable = connections[key]
		if key.is_connected(function_to_call):
			key.disconnect(function_to_call)

func _ready() -> void:
	_build_all_stream_players()
	_recursive_connect_ui_sounds(root_node)
	_connect_minigame_bus()
	persistent = persistent

func _exit_tree() -> void:
	var tree_node = get_tree()
	if tree_node.node_added.is_connected(connect_ui_sounds):
		tree_node.node_added.disconnect(connect_ui_sounds)
	_disconnect_minigame_bus()
