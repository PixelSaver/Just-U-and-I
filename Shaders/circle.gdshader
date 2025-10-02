shader_type canvas_item;

uniform float radius = .5;
uniform float thickness = .4;
uniform vec4 modulate = vec4(vec3(1.), 1.);

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);

    float half_thick = thickness * 0.5;
    float inner = radius - thickness;
    float outer = radius;

    float ring = step(inner, dist) - step(outer, dist);

    COLOR = vec4(modulate.xyz, ring * modulate.q);
}
