extends Node2D

signal player_landed(pos: Vector2)

func _ready() -> void:
	pass

#func kill_unsafe_spikes() -> void:
	#for _body in %SpikeDetector.get_overlapping_bodies():
		#if _body is FallingGameSpike:
			#_body.queue_free()

func reduce_spikes(survival_rate: float) -> void:
	for _spike in %Spikes.get_children():
		if randf() >= survival_rate:
			_spike.queue_free()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is RollingPlayer:
		player_landed.emit(position)
