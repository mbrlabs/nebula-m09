shader_type canvas_item;

const float RADIUS = 24.0;
const float INCREMENT = 0.002;

// Horizontal Gauusian Blur for GLES2.
void fragment() {
	float n = INCREMENT;
	vec4 color = vec4(0);
	float weight = 0.0;
	
	for (float i = -RADIUS; i <= RADIUS; i++) {
		color += texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE * vec2(i, 0.0)) * n;
		n += sign(i) * INCREMENT;
		weight += n;
	}
	
	COLOR = color * (1.0 / weight);
}