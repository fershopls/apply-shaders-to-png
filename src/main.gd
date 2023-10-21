extends Node

"""
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
"""

@onready var texture = $TextureRect
func _ready():
	var args = OS.get_cmdline_args()
	
	var cmd_path = args[0]
	cmd_path = 'C:\\Users\\Personal\\Documents\\Godot\\20231020_png_shaders\\tests\\pngs\\cmd.json'
	
	var cmd_content = FileAccess.get_file_as_string(cmd_path)
	var cmd_json = JSON.parse_string(cmd_content)
	
	if not cmd_json:
		print("error parsing JSON")
		assert(false)
	
	# Populate vars
	var shader_path = cmd_json["shader_path"]
	var fps = cmd_json["fps"]
	var duration = cmd_json["duration"]
	var export_path = cmd_json["export_folder"]
	var win_size = cmd_json["size"]
	var uniforms = cmd_json["uniforms"]
	var ffmpeg_output = cmd_json["ffmpeg_output"]
	var transparent = cmd_json["transparent"]
	
	# Set size
	get_window().size = Vector2i(win_size[0], win_size[1])
	
	# Load shader
	var shader_content = FileAccess.get_file_as_string(shader_path)
	var shader = Shader.new()
	shader.code = shader_content
	texture.material.shader = shader
	
	print('======')
	print(shader.code)
	print('======')
	print('shader loaded')
	
	# set uniforms
	set_uniforms(uniforms)
	
	# set values
	var value_to := 1.
	var duration_fps = duration * float(fps)
	var value_step := value_to / float(duration_fps)
	
	var value: float = 0.0
	
	# fix weird bug
	texture.material.set_shader_parameter('i', value)
	await get_tree().process_frame
	
	var images = []
	
	for i in duration_fps:
		texture.material.set_shader_parameter('i', value)
		await get_tree().process_frame
		
		var image = get_viewport().get_texture().get_image()
		images.append(image)
		
		print(i+1, '/', duration_fps, ' ', name, ' ', value)
		
		value += value_step
	
	var image_format = 'png' if transparent else 'jpg'
	print('exporting ', len(images), ' images as ', image_format)
	await get_tree().process_frame
	
	var i = 0
	for image in images:
		var filename = 'frame_'+str(i)
		var filepath = export_path+"/"+filename
		
		if transparent:
			image.save_png(filepath + ".png")
		else:
			image.save_jpg(filepath + ".jpg")
		
		i += 1
	
	#ffmpeg -y -framerate 30 -i frame_%d.png -c:v libx264 -pix_fmt yuv420p output.mp4
	if ffmpeg_output:
		var os_output = []
		var file_pattern = "/frame_%d.png" if transparent else "/frame_%d.jpg"
		
		if transparent:
			OS.execute("ffmpeg", ["-y", "-framerate", str(fps), "-i", export_path+file_pattern, "-c:v", 'ffv1', '-pix_fmt', 'yuva420p', ffmpeg_output], os_output)
		else:
			OS.execute("ffmpeg", ["-y", "-framerate", str(fps), "-i", export_path+file_pattern, "-c:v", "libx264", "-pix_fmt", "yuv420p", ffmpeg_output], os_output)
		
		print(ffmpeg_output)
	
	get_tree().quit()

func set_parameter(key, value):
	print('set uniform ', key, ' to ', value)
	texture.material.set_shader_parameter(key, value)

func set_image(key, value):
	print('load image from ', value)
	var image = Image.new()
	image.load(value)
	set_parameter(key, ImageTexture.create_from_image(image))

func set_uniforms(uniforms: Dictionary):
	for key in uniforms.keys():
		var value = uniforms[key]
		
		if typeof(value) == TYPE_STRING:
			set_image(key, value)
		elif typeof(value) == TYPE_ARRAY:
			if len(value) == 2:
				set_parameter(key, Vector2(value[0], value[1]))
			elif len(value) == 3:
				set_parameter(key, Vector3(value[0], value[1], value[2]))
			elif len(value) == 4:
				set_parameter(key, Vector4(value[0], value[1], value[2], value[3]))
		else:
			set_parameter(key, value)
