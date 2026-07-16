class_name FogOfWar
extends Sprite2D

# fog of war type of lighting, with specific shader
# uses rgb, where r is dark (0) or bright (1), and g is if it's discovered (1) or not (0)


@export var player: Node2D
@export var maze: Node2D

@export var light_radius: float = 60.0
@export var fade_length: float = 24.0 # width of how much the light source fades to black
@export var explored_visibility: float = 0.5 # either 0 to 1, 1 is most visible


var grid_origin: Vector2 # top left corner
var fog_image: Image
var fog_texture: ImageTexture
var squares_lit_last_frame := []


func setup():
	squares_lit_last_frame.clear()
	
	# 1 pixel per maze, scaled to fit the maze
	fog_image = Image.create(maze.grid_width, maze.grid_height, false, Image.FORMAT_RG8)
	fog_image.fill(Color.BLACK)
	fog_texture = ImageTexture.create_from_image(fog_image)
	material.set_shader_parameter("fog_texture", fog_texture)
	
	texture = fog_texture
	position = maze.grid_offset
	scale = Vector2.ONE * maze.CELL_SIZE
	grid_origin = global_position

func update_fog() -> void:
	dim_squares_not_in_light()
	var squares_lit_this_frame = light_up_squares_near_player()
	squares_lit_last_frame = squares_lit_this_frame
	fog_texture.update(fog_image)

func dim_squares_not_in_light() -> void:
	for index in squares_lit_last_frame:
		var x = index % maze.grid_width
		var y = index / maze.grid_width
		if not (x >= 0 and x < maze.grid_width and y >= 0 and y < maze.grid_height): continue
		
		var world_pos = grid_origin + Vector2(x + 0.5, y + 0.5) * maze.CELL_SIZE
		var distance_to_player = world_pos.distance_to(player.global_position)
		if distance_to_player > light_radius:
			var curr_color = fog_image.get_pixel(x, y)
			fog_image.set_pixel(x, y, Color(explored_visibility, curr_color.g, 0))

func light_up_squares_near_player() -> Array:
	var new_lit_squares := []
	
	var local_pos = to_local(player.global_position)
	var search_range = int(ceil(light_radius + fade_length) / maze.CELL_SIZE) + 1
	var player_x_square = int(local_pos.x)
	var player_y_square = int(local_pos.y)
	
	for y in range(max(0, player_y_square - search_range), min(maze.grid_height, player_y_square + search_range + 1)):
		for x in range(max(0, player_x_square - search_range), min(maze.grid_width, player_x_square + search_range + 1)):
			var world_pos = grid_origin + Vector2(x + 0.5, y + 0.5) * maze.CELL_SIZE
			var distance_to_player = world_pos.distance_to(player.global_position)
			
			var brightness = clamp(1.0 - (distance_to_player - light_radius) / fade_length, 0.0, 1.0)
			if brightness <= 0.01: continue
			
			var was_explored = fog_image.get_pixel(x, y).g > 0.5
			var final_brightness = max(brightness, explored_visibility if was_explored else 0.0)
			fog_image.set_pixel(x, y, Color(final_brightness, 1.0, 0))
			new_lit_squares.append(y * maze.grid_width + x)
	
	return new_lit_squares

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null or fog_image == null: return
	update_fog()
