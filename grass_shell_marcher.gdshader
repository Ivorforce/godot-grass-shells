shader_type spatial;

uniform vec3 base_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 tip_color : source_color = vec3(1.0, 0.0, 0.0);

instance uniform vec2 shift;

uniform float pixel_size = 0.02;
uniform float height = 0.2;
uniform int shell_count = 2;
uniform int march_count = 256;

varying vec3 world_position;

// From https://www.shadertoy.com/view/4djSRW
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

///  3 out, 2 in...
vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy+p3.yzz)*p3.zyx);
}

vec4 hash42(vec2 p)
{
	vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy+33.33);
    return fract((p4.xxyz+p4.yzzw)*p4.zywx);

}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hit_ratio(vec3 pos) {	
	vec2 grid_cell = floor(pos.xz);
	vec3 rand = hash32(grid_cell);

	float strand_height = rand.z * 0.5 + 0.5;
	strand_height = strand_height * strand_height;
	float relative_height = 1.0 + pos.y - strand_height;
	
	vec2 rand_center = 0.5 + (rand.xy - 0.5) * (1.0 - relative_height * 2.0);
	float dist_to_center = length(rand_center - mod(pos.xz, 1.0));
	float width_at_height = 0.5 * (1.1 - relative_height);

	if (dist_to_center > width_at_height) {
		return 2.0;
	}
	
	return relative_height;
}

vec2 march(int steps, vec3 cpos, vec3 forward) {
	for (int i = 0; i < steps; i++) {
		float hr = hit_ratio(cpos);
	    if (hr > 1.0) {
			cpos += forward;
			// MISS
			continue;
		}

		return vec2(hr, float(i));
	}
	return vec2(-1.0, -1.0);
}

void fragment() {
	vec3 forwards = mat3(INV_VIEW_MATRIX) * VIEW;
	forwards.xz = -forwards.xz;
	
	float top_y = world_position.y;
	float bot_y = top_y - height;
	vec3 cpos = vec3(world_position.x / pixel_size, 1.0, world_position.z / pixel_size);
	cpos.xz += shift;
	
	float forward_vecs_per_shell = height / (float(shell_count) * forwards.y);
	vec2 one_shell_forwards_xy = forwards.xz * forward_vecs_per_shell / pixel_size;
	vec3 one_shell_forwards = vec3(one_shell_forwards_xy.x, -1.0 / float(shell_count), one_shell_forwards_xy.y);
	vec2 hit_parallax = march(shell_count, cpos, one_shell_forwards);
	hit_parallax.y /= forward_vecs_per_shell;
	
	///////////////////////
	
	float excess = 2.0;

	float forwards_ratio = forwards.y / float(march_count);
	vec2 forward_march_xy = forwards.xz / float(march_count) / pixel_size * height;
	vec3 forward_march = vec3(forward_march_xy.x, -forwards_ratio, forward_march_xy.y) * excess;
	vec2 hit_march = march(march_count, cpos, forward_march);
	
	if (hit_march.y > hit_parallax.y) {
		hit_parallax = hit_march;
	}
	
	//ALBEDO = forwards;
	
	if (hit_parallax.x < 0.0) {
		discard;
	}
	else {
		ALBEDO = mix(base_color, tip_color, hit_parallax.x * hit_parallax.x);
		DEPTH = hit_parallax.y * -VIEW.z;
	}
}
