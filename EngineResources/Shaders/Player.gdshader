shader_type canvas_item;

uniform vec3 color : source_color = vec3(1,1,1);
uniform float weight : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment(){
	float col = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	vec3 col2 = mix(COLOR.rgb,color,weight);
	COLOR.rgb = mix(vec3(col),col2,1);
}
