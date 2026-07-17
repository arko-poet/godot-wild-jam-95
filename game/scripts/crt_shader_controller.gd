extends Node

signal crt_filter_changed(value: bool)
const CRT_KEY := "CrtFilter"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func is_enabled() -> bool:
	return PlayerConfig.get_config(AppSettings.VIDEO_SECTION, CRT_KEY, true)

func apply_setting() -> void:
	crt_filter_changed.emit(is_enabled())
