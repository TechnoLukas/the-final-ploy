shader_type spatial;
render_mode unshaded;
uniform sampler2D tex;

void fragment() {
	vec4 color = texture(tex, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
