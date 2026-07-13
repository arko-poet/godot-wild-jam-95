extends Node2D

const MiniGameScenes := [
	preload("res://game/scenes/minigames/example_minigame/example_minigame.tscn")
]

var games_won := 0:
	set(value):
		games_won = value
		win_count_label.text = "Games Won: %s" % games_won

var current_mingame: Minigame

@onready var meta_game: Control = %MetaGame
@onready var win_count_label: Label = %WinCountLabel
@onready var screen_content: Control = %ScreenContent


func _on_play_game_button_pressed() -> void:
	meta_game.hide()
	
	current_mingame = MiniGameScenes[0].instantiate()
	screen_content.add_child(current_mingame)
	current_mingame.game_won.connect(_on_minigame_game_won)


func _on_minigame_game_won() -> void:
	games_won += 1
	
	current_mingame.queue_free()
	meta_game.show()
