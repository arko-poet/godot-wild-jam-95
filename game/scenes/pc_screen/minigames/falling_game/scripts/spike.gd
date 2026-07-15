## Dummy class used to verify colliding objects in the falling game only, do not use
class_name FallingGameSpike extends StaticBody2D

# this script just exists so the player can check if the thing it is colliding with
# is a regular floor (no hurt) or a spike (yes hurt). Could do a group but this way
# is more self-contained, requires no global settings, and it is impossible to
# forget to place each and every spike into a local scene group

func _ready() -> void:
	$Area2D.area_entered.connect(_die)

func _die(_area: Area2D) -> void:
	queue_free()
