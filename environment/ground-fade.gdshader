shader_type canvas_item;

void fragment() {
	vec4 original_color = textureLod(TEXTURE, UV, 0.0);
	COLOR = vec4(original_color.rgb, original_color.a * min(UV.y, sqrt(sqrt(1.0 - UV.y))));
}
