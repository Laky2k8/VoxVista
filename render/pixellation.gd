extends ColorRect

# Resizes the ColorRect to be the size of the screen and set pixel size, all this for the pixellation shader

@export var pixel_size: int = 4

func _ready():
	if material and material is ShaderMaterial:
		_update_shader_params()
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))

func _on_viewport_resized():
	_update_shader_params()

func _update_shader_params():
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("screen_size", get_viewport().size)
		mat.set_shader_parameter("pixel_size", float(pixel_size))
