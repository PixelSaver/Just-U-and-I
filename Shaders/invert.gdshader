shader_type canvas_item;

uniform float red_str = 1.0;
uniform float green_str = 1.0;
uniform float blue_str = 1.0;

uniform float alpha_str = 10.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment(){

	vec4 color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, texture(TEXTURE, UV).a);

	COLOR = vec4(1.0 - vec3(color.r * red_str, color.g * green_str,  color.b * blue_str) * alpha_str,  color.a);
//	COLOR.x = 0.0;
}