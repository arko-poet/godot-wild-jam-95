extends Node2D

var games_won := 0:
	set(value):
		games_won = value
		win_count_label.text = "Games Won: %s" % games_won

@onready var meta_game: Control = %MetaGame
@onready var example_minigame: Minigame = %ExampleMinigame
@onready var win_count_label: Label = %WinCountLabel


func _on_play_game_button_pressed() -> void:
	meta_game.hide()
	
	example_minigame.setup()
	example_minigame.show()


func _on_minigame_game_won() -> void:
	games_won += 1
	
	example_minigame.hide()
	meta_game.show()
