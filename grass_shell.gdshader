shader_type spatial;

uniform vec3 base_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 tip_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float pixel_size = 0.02;

instance uniform float height = 0.0;
varying vec4 world_position;

// From https://www.shadertoy.com/view/4djSRW
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void vertex() {
	world_position = MODEL_MATRIX * vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 grid_pos = round(world_position.xz / pixel_size);
    if (hash12(grid_pos) < height) discard;

	ALBEDO = mix(base_color, tip_color, height * height);
}
