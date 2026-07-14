extends Node2D

signal player_landed(pos: Vector2)

const MIN_GAP = 90.0
const MAX_GAP = 175.0
const SPIKE_SURVIVAL_CHANCE = [0.0, 0.1, 0.3, 0.5, 0.7]

@onready var left_starting_x = %Left.position.x
@onready var right_starting_x = %Right.position.x

@export var all_spikes: Array[Node]

@export var first_platform := false ## if true, this platform knows to remove all spikes and set a default gap
@export var last_platform := false ## If true, this platform knows to remove all spikes and have a gap of 0

var gap: float:
	set(value):
		gap = value
		%Left.position.x = left_starting_x - (gap / 2)
		%Right.position.x = right_starting_x + (gap / 2)


func _ready() -> void:
	if first_platform:
		gap = lerpf(MIN_GAP, MAX_GAP, 0.5)
		for _spike in all_spikes:
			_spike.queue_free()
	elif last_platform:
		gap = 0
		for _spike in all_spikes:
			_spike.queue_free()
	else:
		gap = lerpf(MIN_GAP, MAX_GAP, randf())
		for _spike in all_spikes:
			if randf() >= SPIKE_SURVIVAL_CHANCE[2]:
				_spike.queue_free()


func _on_player_detector_body_entered(body: Node2D) -> void:
	player_landed.emit(position)
