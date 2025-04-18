shader_type spatial;

render_mode world_vertex_coords, cull_disabled, vertex_lighting;

uniform float CURVATURE = 5.0;
uniform bool CURVATURE_ACTIVE = true;
uniform float CURVATURE_DISTANCE = 25.0;

uniform sampler2D BASE_TEX;

uniform vec3 camera_position; // Passato da GDScript

void vertex() {
	if (CURVATURE_ACTIVE) {
		vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		float dist = length(world_vertex - camera_position) / CURVATURE_DISTANCE;
		VERTEX.y -= pow(dist, CURVATURE);
	}
}

void fragment() {
	vec4 tex = texture(BASE_TEX, UV);

	if (tex.a < 0.3) {
		discard;
	}

	ALBEDO = tex.rgb;
	ALPHA  = tex.a;
}
