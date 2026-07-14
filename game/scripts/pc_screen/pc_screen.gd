extends Node2D

const MiniGameScenes := [
	preload("res://game/scenes/pc_screen/minigames/example_minigame/example_minigame.tscn"),
	preload("res://game/scenes/pc_screen/minigames/falling_game/prototype_only/falling_game_static.tscn"),
	preload("res://game/minigames/maze_game/scenes/maze_main.tscn"),
]

var games_won := 0:
	set(value):
		games_won = value
		win_count_label.text = "Games Won: %s" % games_won

var current_minigame: Minigame

@onready var meta_game: Control = %MetaGame
@onready var win_count_label: Label = %WinCountLabel
@onready var screen_content: Control = %ScreenContent


func _on_play_game_button_pressed() -> void:
	meta_game.hide()
	
	current_minigame = MiniGameScenes.pick_random().instantiate()
	current_minigame.game_won.connect(_on_minigame_won)
	current_minigame.game_lost.connect(_on_minigame_lost)
	current_minigame.dice_roll = _roll_dice()
	current_minigame.difficulty = Minigame.Difficulty.values().pick_random()
	
	screen_content.add_child(current_minigame)


func _on_minigame_won() -> void:
	games_won += 1
	
	current_minigame.queue_free()
	meta_game.show()


func _on_minigame_lost() -> void:
	current_minigame.queue_free()
	meta_game.show()


func _roll_dice() -> int:
	return 1 + randi() % 6
