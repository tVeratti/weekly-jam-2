shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform float threshold;
uniform float intensity;
uniform float opacity;
uniform vec4 glow_color : source_color;

void fragment() {
	// Get the pixel color from the texture
	vec4 pixel_color = texture(TEXTURE, UV);
	
	// Calculate the distance between the pixel color and the first source color
	float distance = length(pixel_color - color1);
	
	// Calculate the distance between the pixel color and the second source color
	float distance_second = length(pixel_color - color2);
	
	// Create a new variable to store the modified glow color
	vec4 modified_glow_color = glow_color;
	
	// Set the alpha value of the modified glow color to the specified opacity
	modified_glow_color.a = opacity;
}