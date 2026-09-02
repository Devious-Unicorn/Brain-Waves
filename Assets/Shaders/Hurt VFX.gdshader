shader_type canvas_item;

uniform float a = 3;
uniform float c = -0.5;

void fragment() {
	COLOR = vec4(1, 0, 0, a * pow(UV.x - 0.5, 2) + a * pow(UV.y - 0.5, 2) + c);
}
