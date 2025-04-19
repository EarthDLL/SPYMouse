shader_type canvas_item;

uniform vec2 di = vec2(0.5,0.5);
uniform float speed = -1.0;

void fragment() {
	vec2 move = di * TIME * speed;
	COLOR = texture(TEXTURE,UV+move);
}
