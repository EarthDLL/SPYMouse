shader_type canvas_item;

void fragment() {
	COLOR.a = COLOR.a - COLOR.r;
}
