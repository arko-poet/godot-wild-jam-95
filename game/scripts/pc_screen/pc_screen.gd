extends Node2D

signal doom_changed(percentage: float)
signal progress_bar_filled

const MiniGameScenes := [
	preload("res://game/scenes/pc_screen/minigames/example_minigame/example_minigame.tscn"),
	preload("res://game/scenes/pc_screen/minigames/falling_game/prototype_only/falling_game_static.tscn"),
]

const MAX_DOOM := 1.0
const DOOM_STEP := 0.1
const MAX_PROGRESS := 1.0
const PROGRESS_STEP := 0.1

var current_minigame: Minigame
var current_difficulty: Minigame.Difficulty

var doom := 0.0:
	set(value):
		doom = min(value, MAX_DOOM)
		doom_bar.value = doom
		doom_changed.emit(doom)
var progress := 0.0:
	set(value):
		progress = value
		progress_bar.value = min(progress, MAX_PROGRESS)
		if progress == MAX_PROGRESS:
			progress_bar_filled.emit()

@onready var meta_game: Control = %MetaGame
@onready var screen_content: Control = %ScreenContent

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_bar_preview: ProgressBar = %ProgressBarPreview
@onready var doom_bar: ProgressBar = %DoomBar
@onready var doom_bar_preview: ProgressBar = %DoomBarPreview


func _ready() -> void:
	progress_bar.max_value = MAX_PROGRESS
	doom_bar.max_value = MAX_DOOM


func _on_play_game_button_pressed() -> void:
	meta_game.hide()
	
	current_minigame = MiniGameScenes.pick_random().instantiate()
	current_minigame.game_won.connect(_on_minigame_won)
	current_minigame.game_lost.connect(_on_minigame_lost)
	current_minigame.dice_roll = _roll_dice()
	current_difficulty =  Minigame.Difficulty.values().pick_random()
	current_minigame.difficulty = current_difficulty
	
	screen_content.add_child(current_minigame)


func _on_minigame_won() -> void:
	progress_bar.value += PROGRESS_STEP * (current_difficulty + 1)
	
	current_minigame.queue_free()
	meta_game.show()


func _on_minigame_lost() -> void:
	doom_bar.value += DOOM_STEP * (current_difficulty + 1)	
	
	current_minigame.queue_free()
	meta_game.show()


func _roll_dice() -> int:
	doom_bar.value += DOOM_STEP
	
	return 1 + randi() % 6
