class_name ItemHoverOutline

var shader_mat: Material
var outline_thickness: float

func activate_outline():
	shader_mat.set_shader_parameter("line_thickness", outline_thickness)


func deactivate_outline():
	shader_mat.set_shader_parameter("line_thickness", 0.0)
