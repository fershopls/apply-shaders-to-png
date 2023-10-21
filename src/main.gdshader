shader_type canvas_item;

uniform float i : hint_range(0.0, 1.0);

uniform sampler2D image_a;
uniform sampler2D image_b;

void fragment() {
	float t = i;
	//t = sin(TIME * 2.) / 2.0 + 0.5;
	//t = fract(TIME);
	
	t = pow(t, 0.8);
	
	vec4 a = texture(image_a, UV);
	
	vec2 bst = UV;
	bst += vec2(-0.5);
	bst *= 0.5 + 0.5*t;
	bst += vec2(0.5);
	vec4 b = texture(image_b, bst);
	
	COLOR = mix(a, b, t);
}
