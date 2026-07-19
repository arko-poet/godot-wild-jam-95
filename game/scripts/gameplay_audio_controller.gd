extends Node

# Anywhere, put GameplayAudioController.[signal].emit()
# ex: GameplayAudioController.minigame_won.emit()

signal minigame_won(sfx_index: int)
signal minigame_lost(sfx_index: int)
signal minigame_good_event(sfx_index: int)
signal minigame_bad_event(sfx_index: int)
signal minigame_progress(sfx_index: int)
signal dice_roll(sfx_index: int)
signal entity_step(sfx_index: int)
