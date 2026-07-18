extends ParallaxBackground

@export var main_game: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Monster.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(main_game.monster_stage)
	match main_game.monster_stage:
		-1:
			%Monster.visible = true
			%Monster.z_index = 0
			%Monster.scale = Vector2.ONE
			%Monster.position = Vector2(0, 0)
			%MonsterTopHalf.visible = false
			%MonsterBottomHalf.visible = false
		0:
			%Monster.visible = true
			%Monster.z_index = 0
			%Monster.scale = Vector2.ONE
			%Monster.position = Vector2(0, 0)
			%MonsterTopHalf.visible = false
			%MonsterBottomHalf.visible = false
			
		1:
			%Monster.visible = true
			%Monster.z_index = 5
			%Monster.scale = Vector2(0.12, 0.12)
			%Monster.position = Vector2(1647, 380)
			%MonsterTopHalf.visible = true
			%MonsterBottomHalf.visible = false
		2:
			%Monster.visible = true
			%Monster.z_index = 9
			%Monster.scale = Vector2(0.25, 0.25)
			%Monster.position = Vector2(1111, 340)
			%MonsterTopHalf.visible = true
			%MonsterBottomHalf.visible = true
		3:
			%Monster.visible = true
			%Monster.z_index = 11
			%Monster.scale = Vector2(0.5, 0.5)
			%Monster.position = Vector2(1580, 468)
			%MonsterTopHalf.visible = true
			%MonsterBottomHalf.visible = true
		4:
			%Monster.visible = true
			%Monster.z_index = 11
			%Monster.scale = Vector2(1, 1)
			%Monster.position = Vector2(1140, 228)
			%MonsterTopHalf.visible = true
			%MonsterBottomHalf.visible = true
		5:
			%Monster.visible = true
			%Monster.z_index = 19
			%Monster.scale = Vector2(2, 2)
			%Monster.position = Vector2(675, -160)
			%MonsterTopHalf.visible = true
			%MonsterBottomHalf.visible = true
