extends Node2D

enum SQUARE_TYPE {
	EMPTY,
	WALL,
	# Add SPIKE here if added
	GOAL,
}

@onready var tile_sprite = %TileSprite

var square_type : SQUARE_TYPE = SQUARE_TYPE.EMPTY


## Sets the type of the square to be either empty, wall, or goal
## There should be only one goal square
func set_type(new_type : String) -> void:
	match new_type:
		"empty": square_type = SQUARE_TYPE.EMPTY
		"wall": square_type = SQUARE_TYPE.WALL
		"goal": square_type = SQUARE_TYPE.GOAL
	change_texture()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_texture()

# changes the texture based on the square type
func change_texture() -> void:
	match square_type:
		SQUARE_TYPE.EMPTY: tile_sprite.texture = load("uid://cpgkoty6k05o1")
		SQUARE_TYPE.WALL: tile_sprite.texture = load("uid://dkxw34hqycolo")
		SQUARE_TYPE.GOAL: tile_sprite.texture = load("uid://y48jj7lcpeoj")
		_: tile_sprite.texture = load("uid://dbh0lg6phh4fj") # default empty texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
