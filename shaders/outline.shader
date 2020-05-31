shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color : hint_color;

uniform int height = 0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float maxa = col.a;
	float mina = col.a;

	a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);
	
	int clampedHeight = clamp(height + 1, 1, 3);
	int blue = int(col.b * 255.0);
	blue -= blue % 4;
	blue += clampedHeight;
	col.b = float(blue) / 255.0;
	
	vec4 lineCol = outline_color;
	int lineBlue = int(lineCol.b * 255.0);
	lineBlue -= lineBlue % 4;
	lineBlue += clampedHeight;
	lineCol.b = float(lineBlue) / 255.0;

	COLOR = mix(col, lineCol, maxa - mina);
}
