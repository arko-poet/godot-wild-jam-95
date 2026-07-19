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

const _CONGRATULATIONS_TEXT := "YOU MADE IT THIS TIME. YOU'LL BE BACK."
const _TEXT_ROLL_DICE := "TIME FOR A [b]%s[/b] GAME. ROLL NOW."
const _TEXT_REROLL_DICE := "WE WILL GIVE YOU [b]%s[/b] TIME WITH THAT ROLL."
const _TEXT_CHOOSE_DIFFICULTY := "CHOOSE YOUR DIFFICULTY"

const _DICE_RESULT_DESCRIPTOR = {
	1: "BARELY ANY",
	2: "A LITTLE",
	3: "ENOUGH",
	4: "SOME EXTRA",
	5: "PLENTY OF",
	6: "AN EXCESS OF",
}

const  _TEXT_WON := [
	"ALMOST GOT YOU.",
	"GOOD. KEEP GOING.",
	"YES. YES. YES. YES.",
	"LOOK AT HOW GOOD YOU ARE DOING.",
	"FEELING COMFORTABLE? STILL?",
	"WE ARE STILL GETTING CLOSER.",
	"DO NOT FORGET WHAT IS ON THE LINE HERE.",
]

const _TEXT_LOSE := [
	"WE CAN SMELL YOU.",
	"IT'S GETTING EXCITING.",
	"WE ARE ON OUR WAY.",
	"CAREFUL. DON'T LOSE TOO FAST.",
	"DO YOU SEE US?",
	"ARE YOU WORRIED? WE ARE WORRIED.",
	"WE CANNOT WAIT. CANNOT WAIT. CANNOT WAIT."
]

const _REACTION_TIME := 1.5

# for TEXT_ROLL_DICE
const _MAZE_GAME_NAME := "SEARCHING"
const _EXAMPLE_GAME_NAME := "STUPID"
const _FALLING_GAME_NAME := "FALLING"
const _STRATAGEM_GAME_NAME := "QUICK"
const _SNAKE_GAME_NAME := "SLITHERING" # or slithering??

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

var _show_keyboard_controls := true

var _games_finished: int = 0

@onready var _meta_game: Control = %MetaGame
@onready var _screen_content: Control = %ScreenContent
@onready var _screen_container: SubViewportContainer = %SubViewportContainer

@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_bar_preview: ProgressBar = %ProgressBarPreview
@onready var _progress_bar_preview_label: Label = %ProgressBarPreviewLabel
@onready var _doom_bar: ProgressBar = %DoomBar
@onready var _doom_bar_preview: ProgressBar = %DoomBarPreview
@onready var _doom_bar_preview_label: Label = %DoomBarPreviewLabel

@onready var _die: Sprite2D = %Die
@onready var _roll_dice_button: Button = %RollDiceButton
@onready var _reroll_dice_button: Button = %RerollDiceButton
@onready var _start_button: Button = %StartButton
@onready var _or_label: Label = %ORLabel
@onready var _accept_roll_button: Button = %AcceptRollButton
@onready var _continue_button: Button = %ContinueButton
@onready var _buttons_container: HBoxContainer = %ButtonsContainer
@onready var _keys_container: VBoxContainer = %KeysContainer
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
	_games_finished += 1
	_devil_line.text = _get_devil_line_text(true)
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
	_games_finished += 1
	_devil_line.text = _get_devil_line_text(false)
	_continue_button.show()
	if _current_minigame:
		_current_minigame.queue_free()
	_meta_game.show()
	
	GameplayAudioController.minigame_bad_event.emit()
	_continue_button.grab_focus()
	#_prepare_next_minigame()



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
	
	_devil_line.text = _TEXT_REROLL_DICE % _DICE_RESULT_DESCRIPTOR[_current_dice_roll]
	
	_roll_dice_button.hide()
	
	_reroll_dice_button.show()
	_or_label.show()
	_accept_roll_button.show()
	_accept_roll_button.grab_focus()
	
	_doom += _DOOM_ROLL_PRICE


func _on_reroll_dice_button_pressed() -> void:
	await _roll_dice()
	_current_minigame.dice_roll = _current_dice_roll
	_devil_line.text = _TEXT_REROLL_DICE % _DICE_RESULT_DESCRIPTOR[_current_dice_roll]
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
	_doom_bar_preview_label.hide()
	_progress_bar_preview.hide()
	_progress_bar_preview_label.hide()
	
	
	if len(_minigame_queue) > 4: _show_keyboard_controls = false # no need cuz it's shown for every game alr
	if _show_keyboard_controls: _keys_container.show_controls()
	
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
	_progress_bar_preview_label.show()
	_progress_bar_preview_label.text = "+" + str(int(_DOOM_AND_PROGRESS[_get_difficulty()] * 100)) + "%"
	_progress_bar_preview_label.position.x = _progress_bar_preview.position.x + _progress_bar_preview.size.x * clamp(1 - _progress_bar_preview.value, 0.1, 0.9) - _progress_bar_preview_label.size.x
	
	_doom_bar_preview.show()
	_doom_bar_preview.value = _doom + _DOOM_AND_PROGRESS[_get_difficulty()]
	_doom_bar_preview_label.show()
	_doom_bar_preview_label.text = "+" + str(int(_DOOM_AND_PROGRESS[_get_difficulty()] * 100)) + "%"
	_doom_bar_preview_label.position.x = _doom_bar_preview.position.x + _doom_bar_preview.size.x * clamp(_doom_bar_preview.value, 0.05, 0.9)

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


func _get_devil_line_text(_won: bool) -> String:
	if _games_finished == 1:
		return "WE CAN SEE YOU. WELCOME BACK."
	elif _games_finished == 4:
		return "YOU MUST REALLY BE DESPERATE IF YOU ARE BACK."
	elif _games_finished == 6:
		return "WE ARE ALWAYS HERE FOR YOU WHEN YOU NEED US"
	elif _won:
		return _TEXT_WON[randi() % len(_TEXT_WON)]
	else:
		return _TEXT_LOSE[randi() % len(_TEXT_WON)]
	
