shader_type canvas_item;

uniform sampler2D fog_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float visibility = texture(fog_texture, UV).r; // 0 to 1, 0 = hidden, 1 = visible, 0.5 = half
	COLOR = vec4(0, 0, 0, 1.0 - visibility);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
