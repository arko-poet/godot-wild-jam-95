extends Node

@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer

var i = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var interactive = background_music_player.get_stream_playback() as AudioStreamPlaybackInteractive
	interactive.switch_to_clip(i)
	
	i += 1
