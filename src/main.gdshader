shader_type canvas_item;

uniform float i : hint_range(0.0, 1.0);

uniform sampler2D image_a;
uniform sampler2D image_b;

float EaseInOutSine(float x)
{ 
    return -(cos(PI * x) - 1.0) / 2.0;
}

void fragment() {
	float t = i;
	//t = sin(TIME * 2.) / 2.0 + 0.5;
	t = fract(TIME);
	t = EaseInOutSine(t);
	
	vec2 st = UV;
	st += vec2(-0.5);
	st *= 30.0 * (1.0 - t);
	st += vec2(0.5);
	vec4 p = texture(image_a, st);
	
	COLOR = p;
}
