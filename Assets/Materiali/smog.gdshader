shader_type spatial;
render_mode unshaded;

uniform float time_scale = 0.2;
uniform float rect_count = 1.0;
uniform float seed = 1.0;
uniform float rect_scale = 59.0;

float rand(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 + seed);
}

void fragment() {
	vec2 uv = UV;
	vec3 base_color = vec3(0.08); // sfondo scuro
	vec3 col = base_color;

	float t = TIME * time_scale;

	for (int i = 0; i < int(rect_count); i++) {
		float fi = float(i);

		vec2 offset = vec2(
			rand(vec2(fi, 0.0)) * 2.0 - 1.0,
			rand(vec2(fi, 1.0)) * 2.0 - 1.0
		) * 0.4;

		offset += vec2(
			sin(t * rand(vec2(fi, 2.0)) + fi),
			cos(t * rand(vec2(fi, 3.0)) + fi)
		) * 0.15;

		// base_size (0.1–0.4) moltiplicata per il parametro rect_scale
		vec2 base_size = vec2(
			0.1 + rand(vec2(fi, 6.0)) * 0.3,
			0.1 + rand(vec2(fi, 7.0)) * 0.3
		);

		vec2 rect_size = base_size * rect_scale;

		// ✅ rettangoli confinati dentro l'UV anche se ingranditi
		vec2 rect_pos = vec2(
			rand(vec2(fi, 4.0)),
			rand(vec2(fi, 5.0))
		) * (1.0 - rect_size);

		vec2 pos = uv + offset - rect_pos;

		// rettangolo con bordi sfumati
		float inside = smoothstep(0.02, 0.0, abs(pos.x / rect_size.x - 0.5)) *
		               smoothstep(0.02, 0.0, abs(pos.y / rect_size.y - 0.5));

		float grey = 0.1 + rand(vec2(fi, 8.0)) * 0.3;
		col += vec3(grey) * inside;
	}

	col = clamp(col, 0.0, 1.0);
	ALBEDO = col;
}
