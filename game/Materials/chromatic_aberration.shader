shader_type canvas_item;

uniform float ca_strength = 1.0;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float shift = ca_strength / 100.0;
	color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + shift, SCREEN_UV.y)).r;
	color.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
	color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - shift, SCREEN_UV.y)).b;
	COLOR = color;
}