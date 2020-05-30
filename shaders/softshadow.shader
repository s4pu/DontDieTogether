shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(8.0, 8.0);
uniform vec4 modulate : hint_color;

uniform float blurRadius = 1.0;
uniform int sampleRadius = 3;
uniform float shadowAlpha = 1.0;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float maxShadowDistance = length(offset);
	
	float shadowSum = 0.0;
	int shadowSampleCount = 0;
	
	for (int x = -sampleRadius; x <= sampleRadius; x++) {
		for (int y = -sampleRadius; y <= sampleRadius; y++) {
			
			vec2 blurOffset = vec2(float(x), float(y)) / float(sampleRadius) * blurRadius;
			vec2 combinedShadowOffset = (offset + blurOffset) * ps;
			float alpha = texture(TEXTURE, UV - combinedShadowOffset).a;
			
			// use circle shape as mask
			if (length(vec2(float(x), float(y))) > float(sampleRadius)) {
				continue;
			}
			
			shadowSampleCount++;
			shadowSum += alpha * shadowAlpha;
		}
	}
	
	//float sampleCount = pow(1.0 + 2.0 * float(sampleRadius), 2);
	float sampleCount = float(shadowSampleCount);
	float shadowValue = clamp(shadowSum / sampleCount, 0.0, 1.0);
	vec4 shadow = vec4(modulate.rgb, shadowValue);
	
	vec4 col = texture(TEXTURE, UV);
	
	COLOR = mix(shadow, col, col.a);
}
