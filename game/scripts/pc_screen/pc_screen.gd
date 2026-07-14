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

const TEXT_ROLL_DICE := "Lets play a `%s`game. Roll the dice."
const TEXT_REROLL_DICE := "I'll give you %ss to complete the game for that roll."
const TEXT_CHOOSE_DIFFICULTY := "Choose difficulty."

# for TEXT_ROLL_DICE
const MAZE_GAME_NAME := "searching"
const EXAMPLE_GAME_NAME := "stupid"
const FALLING_GAME_NAME := "falling"

var current_minigame: Minigame
var current_difficulty: Minigame.Difficulty
var current_dice_roll: int

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

@onready var dice_roll_label: Label = %DiceRollLabel

@onready var roll_dice_button: Button = %RollDiceButton
@onready var reroll_dice_button: Button = %RerollDiceButton
@onready var start_button: Button = %StartButton
@onready var or_label: Label = %ORLabel
@onready var accept_roll_button: Button = %AcceptRollButton

@onready var difficulty_boxes: GridContainer = %DifficultyBoxes
@onready var easy_check_box: CheckBox = %EasyCheckBox
@onready var medium_check_box: CheckBox = %MediumCheckBox
@onready var hard_check_box: CheckBox = %HardCheckBox

@onready var devil_line: Label = %DevilLine


func _ready() -> void:
	progress_bar.max_value = MAX_PROGRESS
	doom_bar.max_value = MAX_DOOM
	
	_prepare_next_minigame()


func _on_minigame_won() -> void:
	progress_bar.value += PROGRESS_STEP * (current_difficulty + 1)
	
	_prepare_next_minigame()


func _on_minigame_lost() -> void:
	doom += DOOM_STEP * (current_difficulty + 1)
	
	_prepare_next_minigame()


func _prepare_next_minigame() -> void:
	if current_minigame:
		current_minigame.queue_free()
	
	current_minigame = MiniGameScenes.pick_random().instantiate()
	
	if current_minigame is ExampleMinigame:
		devil_line.text = TEXT_ROLL_DICE % EXAMPLE_GAME_NAME
	elif current_minigame is FallingGame:
		devil_line.text = TEXT_ROLL_DICE % FALLING_GAME_NAME
	else:
		devil_line.text = TEXT_ROLL_DICE % MAZE_GAME_NAME
	
	meta_game.show()


func _roll_dice() -> void:
	current_dice_roll = 1 + randi() % 6
	doom += DOOM_STEP / 2.0


func _on_roll_dice_button_pressed() -> void:
	_roll_dice()
	dice_roll_label.text = "%s" % current_dice_roll
	current_minigame.dice_roll = current_dice_roll
	
	devil_line.text = TEXT_REROLL_DICE % current_minigame.get_time_limit()
	
	roll_dice_button.hide()
	
	dice_roll_label.show()
	reroll_dice_button.show()
	or_label.show()
	accept_roll_button.show()


func _on_reroll_dice_button_pressed() -> void:
	_roll_dice()
	dice_roll_label.text = "%s" % current_dice_roll
	current_minigame.dice_roll = current_dice_roll
	devil_line.text = TEXT_REROLL_DICE % current_minigame.get_time_limit()


func _on_accept_roll_button_pressed() -> void:
	reroll_dice_button.hide()
	or_label.hide()
	accept_roll_button.hide()
	dice_roll_label.hide()
	
	devil_line.text = TEXT_CHOOSE_DIFFICULTY
	
	start_button.show()
	difficulty_boxes.show()


func _on_start_button_pressed() -> void:
	meta_game.hide()

	current_minigame.game_won.connect(_on_minigame_won)
	current_minigame.game_lost.connect(_on_minigame_lost)
	current_minigame.dice_roll = current_dice_roll
	current_difficulty =  _get_difficulty()
	current_minigame.difficulty = current_difficulty
	
	screen_content.add_child(current_minigame)
	
	start_button.hide()
	difficulty_boxes.hide()
	
	roll_dice_button.show()


func _on_easy_check_box_pressed() -> void:
	medium_check_box.button_pressed = false
	hard_check_box.button_pressed = false


func _on_medium_check_box_pressed() -> void:
	easy_check_box.button_pressed = false
	hard_check_box.button_pressed = false


func _on_hard_check_box_pressed() -> void:
	easy_check_box.button_pressed = false
	medium_check_box.button_pressed = false


func _get_difficulty() -> Minigame.Difficulty:
	if easy_check_box.button_pressed:
		return Minigame.Difficulty.EASY
	elif medium_check_box.button_pressed:
		return Minigame.Difficulty.MEDIUM
	elif hard_check_box.button_pressed:
		return Minigame.Difficulty.HARD

	push_error("No difficulty checkbox is pressed")
	return Minigame.Difficulty.EASY
