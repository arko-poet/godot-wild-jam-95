extends Node2D

signal doom_changed(percentage: float)
signal progress_bar_filled

const _MiniGameScenes := [
	#preload("res://game/scenes/pc_screen/minigames/example_minigame/example_minigame.tscn"),
	preload("res://game/scenes/pc_screen/minigames/falling_game/scenes/falling_game_main.tscn"),
	preload("res://game/scenes/pc_screen/minigames/maze_game/scenes/maze_main.tscn"),
	preload("res://game/scenes/pc_screen/minigames/stratagem/stratagem.tscn"),
	preload("res://game/scenes/pc_screen/minigames/snake_game/scenes/snake_main.tscn")
]

const _MAX_DOOM := 1.0
const _MAX_PROGRESS := 1.0
const _DOOM_AND_PROGRESS := {
	Minigame.Difficulty.EASY: 0.04,
	Minigame.Difficulty.MEDIUM: 0.06,
	Minigame.Difficulty.HARD: 0.08,
}
const _DOOM_ROLL_PRICE := 0.05
const _DOOM_REROLL_PRICE := 0.01

const _CONGRATULATIONS_TEXT := "Congratulations, you win. Claim your prize."
const _TEXT_ROLL_DICE := "Lets play a [b][u]%s[/u][/b] game. Roll the dice."
const _TEXT_REROLL_DICE := "We'll give you [b][u]%ss[/u][/b] to complete the game for that roll."
const _TEXT_CHOOSE_DIFFICULTY := "Choose difficulty."

const  _TEXT_WON := [
	"Not bad... for now.",
	"Hmm. Beginner's luck, that's all.",
	"Fine. You earned a second of relief.",
	"You won't be so lucky next time.",
	"Next time, We'll make sure you struggle.",
]

const _TEXT_LOSE := [
	"As expected of a mere mortal.",
	"Oh, was that too difficult for you? Too bad.",
	"Struggling already? Keep it up!",
	"Don't worry, you won't win next time too.",
	"Bruh",
]

const _REACTION_TIME := 1.5

# for TEXT_ROLL_DICE
const _MAZE_GAME_NAME := "searching"
const _EXAMPLE_GAME_NAME := "stupid"
const _FALLING_GAME_NAME := "falling"
const _STRATAGEM_GAME_NAME := "quick"
const _SNAKE_GAME_NAME := "eating" # or slithering??

const BAR_FILL_TIME := 0.5

var _minigame_queue: Array
var _current_minigame: Minigame
var _current_dice_roll: int

var _doom := 0.0:
	set(value):
		var tween = create_tween()
		tween.tween_property(_doom_bar, ^"value", min(value, _MAX_DOOM), BAR_FILL_TIME)
		await tween.finished
		_doom = min(value, _MAX_DOOM)
		doom_changed.emit(_doom)
		
var _progress := 0.0:
	set(value):
		var tween = create_tween()
		tween.tween_property(_progress_bar, ^"value", min(value, _MAX_PROGRESS), BAR_FILL_TIME)
		await tween.finished
		_progress = min(value, _MAX_PROGRESS)
		if _progress == _MAX_PROGRESS:
			_progress_bar_filled()

@onready var _meta_game: Control = %MetaGame
@onready var _screen_content: Control = %ScreenContent
@onready var _screen_container: SubViewportContainer = %SubViewportContainer

@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_bar_preview: ProgressBar = %ProgressBarPreview
@onready var _doom_bar: ProgressBar = %DoomBar
@onready var _doom_bar_preview: ProgressBar = %DoomBarPreview

@onready var _die: Sprite2D = %Die
@onready var _roll_dice_button: Button = %RollDiceButton
@onready var _reroll_dice_button: Button = %RerollDiceButton
@onready var _start_button: Button = %StartButton
@onready var _or_label: Label = %ORLabel
@onready var _accept_roll_button: Button = %AcceptRollButton
@onready var _continue_button: Button = %ContinueButton
@onready var _buttons_container: HBoxContainer = %ButtonsContainer
@onready var accept_contract_button: Button = %AcceptContractButton
@onready var claim_prize_button: Button = %ClaimPrizeButton

@onready var _difficulty_boxes: GridContainer = %DifficultyBoxes
@onready var _easy_check_box: CheckBox = %EasyCheckBox
@onready var _medium_check_box: CheckBox = %MediumCheckBox
@onready var _hard_check_box: CheckBox = %HardCheckBox

@onready var _devil_line: RichTextLabel = %DevilLine
@onready var devil_container: HBoxContainer = %DevilContainer

@onready var contract: Panel = %Contract


func _ready() -> void:
	randomize()
	_progress_bar.max_value = _MAX_PROGRESS
	_progress_bar_preview.max_value = _MAX_PROGRESS
	_doom_bar.max_value = _MAX_DOOM
	_doom_bar_preview.max_value = _MAX_DOOM
	
	# Add first set of 4 games in random order
	_minigame_queue.append_array(_MiniGameScenes)
	_minigame_queue.shuffle()
	
	_prepare_next_minigame()
	

func play_power_on_animation() -> void:
	show()
	
	_screen_container.scale = Vector2(1.0, 0.02)
	_screen_container.modulate = Color.DIM_GRAY
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_screen_container, "scale:y", 1.0, 0.35)\
		.set_delay(0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_screen_container, "modulate", Color.WHITE, 0.35)\
		.set_delay(0.15)
	
	if contract.visible:
		accept_contract_button.grab_focus()
	else:
		_roll_dice_button.grab_focus()


func _on_minigame_won() -> void:
	if MinigameTimeTrials.trials_active:
		MinigameTimeTrials.print_minigame_time()
		MinigameTimeTrials.stop_timer()
	
	_progress += _DOOM_AND_PROGRESS[_get_difficulty()]
	
	#await _show_reaction(true)
	_devil_line.text = _TEXT_WON[randi() % len(_TEXT_WON)]
	_continue_button.show()
	if _current_minigame:
		_current_minigame.queue_free()
	_meta_game.show()
	
	GameplayAudioController.minigame_won.emit()
	_continue_button.grab_focus()
	#_prepare_next_minigame()


func _on_minigame_lost() -> void:
	_doom += _DOOM_AND_PROGRESS[_get_difficulty()]
	
	#await _show_reaction(false)
	_devil_line.text = _TEXT_LOSE[randi() % len(_TEXT_LOSE)]
	_continue_button.show()
	if _current_minigame:
		_current_minigame.queue_free()
	_meta_game.show()
	
	GameplayAudioController.minigame_bad_event.emit()
	_continue_button.grab_focus()
	#_prepare_next_minigame()


#func _show_reaction(won: bool) -> void:
	#if won:
		#_devil_line.text = _TEXT_WON[randi() % len(_TEXT_WON)]
	#else:
		#_devil_line.text = _TEXT_LOSE[randi() % len(_TEXT_LOSE)]
	#
	#_roll_dice_button.hide()
	#_reroll_dice_button.hide()
	#_or_label.hide()
	#_accept_roll_button.hide()
	#_dice_roll_label.hide()
	#_start_button.hide()
	#_difficulty_boxes.hide()
	#
	#_meta_game.show()
	#
	#await get_tree().create_timer(_REACTION_TIME).timeout


func _prepare_next_minigame() -> void:
	if MinigameTimeTrials.trials_active:
		_current_minigame = _MiniGameScenes[MinigameTimeTrials.force_minigame_index].instantiate()
	else:
		if len(_minigame_queue) == 0:
			_minigame_queue.append_array(_MiniGameScenes)
			_minigame_queue.append_array(_MiniGameScenes) # append it twice so we don't get the usual pattern of sets of 4 minigames
			_minigame_queue.shuffle()
		
		_current_minigame = _minigame_queue.front().instantiate()
		_minigame_queue.pop_front()
	
	if _current_minigame is FallingGame:
		_devil_line.text = _TEXT_ROLL_DICE % _FALLING_GAME_NAME
	elif _current_minigame is Stratagem:
		_devil_line.text = _TEXT_ROLL_DICE % _STRATAGEM_GAME_NAME
	elif _current_minigame is SnakeGame:
		_devil_line.text = _TEXT_ROLL_DICE % _SNAKE_GAME_NAME
	elif _current_minigame is MazeGame:
		_devil_line.text = _TEXT_ROLL_DICE % _MAZE_GAME_NAME
	else: # example minigame
		_devil_line.text = _TEXT_ROLL_DICE % _EXAMPLE_GAME_NAME
	
	
	show_roll_die_bar_preview()
	_roll_dice_button.grab_focus()
	_meta_game.show()


func _roll_dice() -> void:
	GameplayAudioController.dice_roll.emit()
	_die.show()
	
	_buttons_container.hide()
	
	_die.roll(1 + randi() % 6)
	await _die.roll_finished
	
	_buttons_container.show()


func _on_die_roll_finished(value: int) -> void:
	#print(value)
	_current_dice_roll = value


func _on_roll_dice_button_pressed() -> void:
	await _roll_dice()
	_current_minigame.dice_roll = _current_dice_roll
	
	_devil_line.text = _TEXT_REROLL_DICE % _current_minigame.get_time_limit()
	
	_roll_dice_button.hide()
	
	_reroll_dice_button.show()
	_or_label.show()
	_accept_roll_button.show()
	_accept_roll_button.grab_focus()
	
	_doom += _DOOM_ROLL_PRICE


func _on_reroll_dice_button_pressed() -> void:
	await _roll_dice()
	_current_minigame.dice_roll = _current_dice_roll
	_devil_line.text = _TEXT_REROLL_DICE % _current_minigame.get_time_limit()
	_reroll_dice_button.grab_focus()
	
	_doom += _DOOM_REROLL_PRICE


func _on_accept_roll_button_pressed() -> void:
	_reroll_dice_button.hide()
	_or_label.hide()
	_accept_roll_button.hide()
	_die.hide()
	
	_devil_line.text = _TEXT_CHOOSE_DIFFICULTY
	
	_start_button.show()
	_difficulty_boxes.show()
	_show_bar_previews()
	
	if _easy_check_box.button_pressed: _easy_check_box.grab_focus()
	elif _hard_check_box.button_pressed: _hard_check_box.grab_focus()
	else: _medium_check_box.grab_focus()


func _on_start_button_pressed() -> void:
	_meta_game.hide()

	_current_minigame.game_won.connect(_on_minigame_won)
	_current_minigame.game_lost.connect(_on_minigame_lost)
	_current_minigame.dice_roll = _current_dice_roll
	_current_minigame.difficulty = _get_difficulty()
	
	_screen_content.add_child(_current_minigame)
	
	_start_button.hide()
	_difficulty_boxes.hide()
	_doom_bar_preview.hide()
	_progress_bar_preview.hide()
	
	if MinigameTimeTrials.trials_active:
		MinigameTimeTrials.start_timer()


func _on_easy_check_box_pressed() -> void:
	_easy_check_box.button_pressed = true
	_medium_check_box.button_pressed = false
	_hard_check_box.button_pressed = false
	
	_show_bar_previews()


func _on_medium_check_box_pressed() -> void:
	_easy_check_box.button_pressed = false
	_medium_check_box.button_pressed = true
	_hard_check_box.button_pressed = false
	
	_show_bar_previews()


func _on_hard_check_box_pressed() -> void:
	_easy_check_box.button_pressed = false
	_medium_check_box.button_pressed = false
	_hard_check_box.button_pressed = true
	
	_show_bar_previews()


func _get_difficulty() -> Minigame.Difficulty:
	if _easy_check_box.button_pressed:
		return Minigame.Difficulty.EASY
	elif _medium_check_box.button_pressed:
		return Minigame.Difficulty.MEDIUM
	elif _hard_check_box.button_pressed:
		return Minigame.Difficulty.HARD

	push_error("No difficulty checkbox is pressed")
	return Minigame.Difficulty.EASY


func _show_bar_previews() -> void:
	_progress_bar_preview.show()
	_progress_bar_preview.value = _progress + _DOOM_AND_PROGRESS[_get_difficulty()]
	_doom_bar_preview.show()
	_doom_bar_preview.value = _doom + _DOOM_AND_PROGRESS[_get_difficulty()]

func show_roll_die_bar_preview() -> void:
	_doom_bar_preview.show()
	_doom_bar_preview.value = _doom + _DOOM_ROLL_PRICE

func show_reroll_die_bar_preview() -> void:
	_doom_bar_preview.show()
	_doom_bar_preview.value = _doom + _DOOM_REROLL_PRICE

func hide_reroll_die_bar_preview() -> void:
	_doom_bar_preview.hide()

func _on_continue_button_pressed() -> void:
	_continue_button.hide()
	_prepare_next_minigame()
	_roll_dice_button.show()


func _on_reroll_dice_button_focus_entered() -> void:
	show_reroll_die_bar_preview()

func _on_reroll_dice_button_focus_exited() -> void:
	hide_reroll_die_bar_preview()


func _on_accept_contract_button_pressed() -> void:
	accept_contract_button.hide()
	contract.hide()
	_roll_dice_button.show()
	devil_container.show()
	_roll_dice_button.grab_focus()

func _progress_bar_filled() -> void:
	_devil_line.text = _CONGRATULATIONS_TEXT
	for child in _buttons_container.get_children():
		child.hide()
	claim_prize_button.show()
	
	#progress_bar_filled.emit()


func _on_claim_prize_button_pressed() -> void:
	progress_bar_filled.emit()
