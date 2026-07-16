extends Node2D

const GAME_SIZE := Vector2(660, 490)

var arrows: Array[Sprite2D]


func _ready() -> void:
	draw_arrows(5)


func draw_arrows(number_of_arrows: int) -> void:
	var p := Vector2(0, 0)
	for i in number_of_arrows:
		var arrow := Sprite2D.new()
		arrow.texture = load("res://game/art/placeholders/stratagem/triangle.png")
		arrow.position = p
		arrow.scale = Vector2(0.2, 0.2)
		arrow.rotate(TAU / 4.0)
		arrow.modulate = Color.GREEN
		add_child(arrow)
		p.x += 100
