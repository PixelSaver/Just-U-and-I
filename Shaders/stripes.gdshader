shader_type canvas_item;

uniform float angle_degrees : hint_range(-180, 180) = 30.0;
uniform float stripe_width : hint_range(0.001, 1.0) = 0.1; // width of stripe itself
uniform float separation : hint_range(0.0, 1.0) = 0.1;     // extra gap after each stripe
uniform vec4 color_a : source_color = vec4(1.0, 1.0, 1.0, 1.0); // stripe color
uniform vec4 color_b : source_color = vec4(0.0, 0.0, 0.0, 1.0); // background color
uniform float smoothness : hint_range(0.0, 0.5) = 0.02;
uniform float tiling : hint_range(0.1, 10.0) = 1.0;
uniform float offset : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV * tiling;

    // rotate UV
    float a = radians(angle_degrees);
    float ca = cos(a);
    float sa = sin(a);
    vec2 ruv = vec2(ca * uv.x - sa * uv.y, sa * uv.x + ca * uv.y);

    // effective stripe + gap length
    float period = stripe_width + separation;

    // stripe coordinate along rotated X
    float coord = ruv.x + offset + TIME * 0.05;

    // find where we are inside the current period
    float stripe_pos = mod(coord, period);

    // inside stripe region?
    float mask = smoothstep(0.0, smoothness, stripe_width - stripe_pos);

    vec4 col = mix(color_b, color_a, mask);
    COLOR = col;
}
