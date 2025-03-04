shader_type canvas_item;

uniform float alpha: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec3 color: source_color;
uniform bool fill;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	if (fill){
		COLOR.rgb = color;
	}

	COLOR.a = tex.a * alpha;
}
