shader_type canvas_item;

uniform vec4 tint_color : hint_color = vec4(1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	COLOR = clamp(col * tint_color, vec4(0.0), vec4(1.0));
}
