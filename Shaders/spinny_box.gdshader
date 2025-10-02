shader_type canvas_item;

//uniform vec2 mouse : hint_range(-1.0, 1.0); // pass mouse pos normalized yourself

// ---------------- Palette ----------------
vec3 palette(float t) {
    vec3 a = vec3(0.5,0.5,0.5);
	vec3 b = vec3(0.5,0.5,0.5);
	vec3 c = vec3(1.0,1.0,0.5);
	vec3 d = vec3(0.8,0.90,0.30);
    return a + b * cos(6.28318 * (c * t + d));
}

// ---------------- SDFs ----------------
float sdBoxFrame(vec3 p, vec3 b, float e) {
    p = abs(p) - b;
    vec3 q = abs(p + e) - e;
    return min(min(
        length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0),
        length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)),
        length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}

float sdSphere(vec3 p, float s) {
    return length(p) - s;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

// ---------------- Helpers ----------------
vec3 rot3D(vec3 p, vec3 axis, float angle) {
    axis = normalize(axis);
    return mix(dot(axis, p) * axis, p, cos(angle))
         + cross(axis, p) * sin(angle);
}

mat2 rot2D(float a) {
    float s = sin(a), c = cos(a);
    return mat2(vec2(c, -s), 
				vec2(s, c));
}

vec3 dynamicAxis(float t, vec3 seed) {
    return normalize(vec3(
        sin(t * seed.x),
        cos(t * seed.y),
        -cos(t * seed.z)
    ));
}

// ---------------- Scene ----------------
vec2 map(vec3 p) {
    float oct = sdOctahedron(p, 1.);

    vec3 q = p;

    // Box 1
    float t1 = TIME;
    vec3 a1 = dynamicAxis(t1, vec3(1.2, 1.1, 1.63));
    vec3 a2 = dynamicAxis(t1, vec3(1.6, 1.8, 1.05));
    vec3 p1 = rot3D(q, a1, t1 * 0.7);
    p1 = rot3D(p1, a2, t1 * 1.3);
    float box1 = sdBoxFrame(p1, vec3(1.5), 0.1);

    // Box 2
    float t2 = TIME * 1.37 + 2.5;
    vec3 b1 = dynamicAxis(t2, vec3(0.9, 1.4, 1.77));
    vec3 b2 = dynamicAxis(t2, vec3(1.3, 1.9, 0.85));
    vec3 p2 = rot3D(q, b1, t2 * 0.6);
    p2 = rot3D(p2, b2, t2 * 0.2);
    float box2 = sdBoxFrame(p2, vec3(2.2), 0.1);

    // Box 3
    float t3 = TIME * 0.91 + 4.1;
    vec3 c1 = dynamicAxis(t3, vec3(1.7, 0.8, 1.25));
    vec3 c2 = dynamicAxis(t3, vec3(1.5, 1.2, 1.9));
    vec3 p3 = rot3D(q, c1, t3 * 1.1);
    p3 = rot3D(p3, c2, t3 * 0.4);
    float box3 = sdBoxFrame(p3, vec3(3.0), 0.1);

    // Box 4
    float t4 = TIME * 1.73 + 7.3;
    vec3 d1 = dynamicAxis(t4, vec3(0.6, 1.3, 2.1));
    vec3 d2 = dynamicAxis(t4, vec3(1.9, 1.0, 0.7));
    vec3 p4 = rot3D(q, d1, t4 * 0.5);
    p4 = rot3D(p4, d2, t4 * 1.4);
    float box4 = sdBoxFrame(p4, vec3(4.5), 0.1);

    // Box 5
    float t5 = TIME * 0.53 + 1.7;
    vec3 e1 = dynamicAxis(t5, vec3(1.1, 2.0, 0.9));
    vec3 e2 = dynamicAxis(t5, vec3(0.8, 1.5, 1.3));
    vec3 p5 = rot3D(q, e1, t5 * 0.9);
    p5 = rot3D(p5, e2, t5 * 0.3);
    float box5 = sdBoxFrame(p5, vec3(2.2), 0.1);
	
	float final = min(min(min(box1, oct), min(box2, box3)), min(box4, 1000.));
	float oct_hit = (final - oct < 0.001) ? 1.0 : 0.0;
    return vec2(final, oct_hit);
}

// ---------------- Fragment ----------------
void fragment() {
	vec2 resolution = vec2(1.0) / TEXTURE_PIXEL_SIZE;

    // Center UV (-1..1) with proper aspect
    vec2 uv = (UV * 2.0 - 1.0);
    uv.x *= resolution.x / resolution.y;

    // Camera setup
    vec3 ray_origin = vec3(0.0, 0.0, -12.0);
    vec3 ray_dir = normalize(vec3(uv * 0.7, 1.0));
    vec3 col = vec3(0.0);

	
	float alph = 1.0; // if its the octagon in the middle, set transparent
	
    float tot_dist = 0.0;
	int index;
    for (int i = 0; i < 80; i++) {
        vec3 pos = ray_origin + ray_dir * tot_dist;
		vec2 map_output = map(pos);
        float dist = map_output.x;
        tot_dist += dist;
		
		index = i;
        if (dist > 100.0) {
            tot_dist = 0.0;
            break;
        }
        else if (dist < 0.001) break;
		else if (map_output.y == 1.){
			alph = 0.;
		}
    }
	
    col = palette(tot_dist*.02 + float(index)*.005 + 3.1);
    if (tot_dist == 0.0) col = vec3(0.0);
	//else {
		//col = vec3(0.21176470588235294, 0.23921568627450981, 0.2901960784313726);
	//}
    COLOR = vec4(col, alph);
}
