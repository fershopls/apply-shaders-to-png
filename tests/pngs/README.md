# Usage
```bash
apply_shader.console.exe cmd.json
```

# Important
- Shader should be in Godot 4 Shading Language
- If transparent is true, output should be .mkv
- If no ffmpeg_output provided, it will skip the video making, only will render frames
- export_folder must exists and should be empty
- uniform i is reserved for shader progress

# Format of CMD
```json

{
	"size": [512, 512],
	"fps": 30,
	"duration": 0.3,
	"ffmpeg_output": "C:\\Users\\Personal\\Documents\\Godot\\20231020_png_shaders\\releases\\frames\\output.mp4",
	"shader_path": "C:\\Users\\Personal\\Documents\\Godot\\20231020_png_shaders\\releases\\shader.gdshader",
	"export_folder": "C:\\Users\\Personal\\Documents\\Godot\\20231020_png_shaders\\releases\\frames",
	"transparent": false,
	"uniforms": {
		"image_a": "C:\\Users\\Personal\\Documents\\Godot\\20231020_png_shaders\\releases\\image_a.jpg",
		"image_b": "C:\\Users\\Personal\\Documents\\Godot\\20231020_png_shaders\\releases\\image_b.jpg"
	}
}
```

# Uniforms
- Arrays will be casted into corresponding Vectors
- Strings will be casted into textures
- floats and ints same

# Shader example
```
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
	//t = fract(TIME);
	t = EaseInOutSine(t);
	
	vec2 st = UV;
	st.x += t;
	vec4 a = texture(image_a, st);
	st = UV;
	st.x += t - 1.;
	vec4 b = texture(image_b, st);
	
	COLOR = step(UV.x, 1.0 - t) * a + (1.0 - step(UV.x, 1.0 - t)) * b;
}
```