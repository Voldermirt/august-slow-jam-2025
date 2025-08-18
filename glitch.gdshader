shader_type canvas_item;

uniform float offset = 0.0;
uniform float rotation_ratio = 0.0;

//void vertex() {
//	// Called for every vertex the material is visible on.
//}

void fragment() {
	//COLOR = texture(TEXTURE, vec2(UV.x + offset * SCREEN_PIXEL_SIZE.x, UV.y));
	float rot1 = rotation_ratio * 2.0 * PI;
	float rot2 = (rotation_ratio + 0.33333) * 2.0 * PI;
	float rot3 = (rotation_ratio + 0.66667) * 2.0 * PI;
	COLOR.r = texture(TEXTURE, UV + SCREEN_PIXEL_SIZE * offset * vec2(cos(rot1), sin(rot1))).r;
	COLOR.g = texture(TEXTURE, UV + SCREEN_PIXEL_SIZE * offset * vec2(cos(rot2), sin(rot2))).g;
	COLOR.b = texture(TEXTURE, UV + SCREEN_PIXEL_SIZE * offset * vec2(cos(rot3), sin(rot3))).b;
}
