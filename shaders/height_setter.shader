shader_type canvas_item;

uniform int height = 0; // 0 = nearly no shadow, 1 = some shadow, 2 = a lot of shadow

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	int clampedHeight = clamp(height + 1, 1, 3);
	
	int blue = int(col.b * 255.0);
	blue -= blue % 4;
	blue += clampedHeight;
	col.b = float(blue) / 255.0;

	COLOR = col;
}
