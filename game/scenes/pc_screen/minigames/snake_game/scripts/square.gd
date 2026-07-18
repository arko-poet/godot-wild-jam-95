extends Node2D

const SPRITE_SHEET := preload("uid://c7imviryubf45")
const REGIONS := {
	"head": Rect2(0, 0, 128, 128),
	"straight": Rect2(0, 128, 128, 128),
	"corner": Rect2(0, 256, 128, 128),
	"tail": Rect2(0, 384, 128, 128),
}

enum SQUARE_TYPE {
	EMPTY,
	WALL,
	# Add SPIKE here if added
	SNAKE,
	APPLE
}

@onready var tile_sprite = %TileSprite

var square_type : SQUARE_TYPE = SQUARE_TYPE.EMPTY


## Sets the type of the square to be either empty, wall, or goal
## There should be only one goal square
func set_type(new_type : String, rotation_degrees: float = 0.0) -> void:
	if REGIONS.has(new_type):
		square_type = SQUARE_TYPE.SNAKE
		%TileSprite.texture = SPRITE_SHEET
		%TileSprite.region_enabled = true
		%TileSprite.region_rect = REGIONS[new_type]
		%TileSprite.rotation_degrees = rotation_degrees
		return
	match new_type:
		"empty": square_type = SQUARE_TYPE.EMPTY
		"wall": square_type = SQUARE_TYPE.WALL
		#"snake": square_type = SQUARE_TYPE.SNAKE
		"apple": square_type = SQUARE_TYPE.APPLE
	
	%TileSprite.region_enabled = false
	%TileSprite.rotation_degrees = 0.0
	change_texture()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_texture()

# changes the texture based on the square type
func change_texture() -> void:
	if square_type == SQUARE_TYPE.SNAKE: return
	match square_type:
		SQUARE_TYPE.EMPTY: tile_sprite.texture = load("uid://d1at6kl2ydnbd")
		SQUARE_TYPE.WALL: tile_sprite.texture = load("uid://b3r566l2fkiig")
		SQUARE_TYPE.SNAKE: tile_sprite.texture = load("uid://da8cmy2fv7dvu")
		SQUARE_TYPE.APPLE: tile_sprite.texture = load("uid://lgfu3ocavbai")
		_: tile_sprite.texture = load("uid://d1at6kl2ydnbd") # default empty texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
