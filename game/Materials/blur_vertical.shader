shader_type canvas_item;

const float RADIUS = 24.0;
const float INCREMENT = 0.002;

// Gauusian blur for GLES2. Based on https://postimg.cc/7JDJw80d
void fragment() {
	float n = INCREMENT;
	vec2 px = SCREEN_PIXEL_SIZE;
	vec4 col = vec4(0);
	float weight = 0.0;
	float norm = 0.0;
	
	for (float i = -RADIUS; i <= RADIUS; i++) {
		col += texture(SCREEN_TEXTURE, SCREEN_UV + px * vec2(0.0, i)) * n;
		if (i <= 0.0) n += INCREMENT;
		if (i > 0.0) n -= INCREMENT;
		weight += n;
	}
	
	norm = 1.0 / weight;
	COLOR = col*norm;
}