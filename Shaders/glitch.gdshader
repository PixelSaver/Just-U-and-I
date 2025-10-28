/*
	Glitch Effect Shader by Yui Kinomoto @arlez80

	MIT License
*/
shader_type canvas_item;

// Strength of the horizontal shake
uniform float shake_power = 0.03;
// Chance of shake per frame
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
// Speed of shake changes
uniform float shake_speed = 5.0;
// Block height in pixels (constant screen size)
uniform float shake_block_size = 30.0;
// Color separation distance
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.01;

// Screen texture
uniform sampler2D screen_texture : hint_screen_texture;

float random(float seed) {
	return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
	float enable_shift = float(random(trunc(TIME * shake_speed)) < shake_rate);

	// Convert SCREEN_UV to pixel coordinates
	vec2 screen_pixel = SCREEN_UV / SCREEN_PIXEL_SIZE;
	
	// Divide by pixel-based block size
	float block_y = trunc(screen_pixel.y / shake_block_size) * shake_block_size;
	
	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		random(block_y + TIME) - 0.5
	) * shake_power * enable_shift;

	vec4 pixel_color = textureLod(screen_texture, fixed_uv, 0.0);
	pixel_color.r = mix(
		pixel_color.r,
		textureLod(screen_texture, fixed_uv + vec2(shake_color_rate, 0.0), 0.0).r,
		enable_shift
	);
	pixel_color.b = mix(
		pixel_color.b,
		textureLod(screen_texture, fixed_uv + vec2(-shake_color_rate, 0.0), 0.0).b,
		enable_shift
	);
	COLOR = pixel_color;
}
