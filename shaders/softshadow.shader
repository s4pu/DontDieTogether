shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(8.0, 8.0);
uniform vec4 modulate : hint_color;

uniform float blurRadius = 1.0;

uniform int sampleRadius = 3;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	
	float shadowSum = 0.0;
	
	for (int x = -sampleRadius; x <= sampleRadius; x++) {
		for (int y = -sampleRadius; y <= sampleRadius; y++) {
			vec2 currentOffset = vec2(float(x), float(y)) / float(sampleRadius) * blurRadius;
			shadowSum += texture(TEXTURE, UV - (offset + currentOffset) * ps).a * modulate.a;
		}
	}
	
	float shadowValue = min(1.0, shadowSum / pow(1.0 + 2.0 * float(sampleRadius), 2));
	vec4 shadow = vec4(modulate.rgb, shadowValue);
	
	vec4 col = texture(TEXTURE, UV);

	COLOR = mix(shadow, col, col.a);
}
