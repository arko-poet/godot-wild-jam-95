extends Node

# Anywhere, put GameplayAudioController.[signal].emit()
# ex: GameplayAudioController.minigame_won.emit()

signal minigame_won
signal minigame_lost
signal minigame_good_event
signal minigame_bad_event
signal minigame_progress
signal dice_roll
signal entity_step
