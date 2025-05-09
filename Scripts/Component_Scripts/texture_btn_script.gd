extends Control

var shader_mat = $".".material
@export var loading_modal: Control
@export var scene_path: String
@export var tool_tip: String
@export var title: String
@export var description: String

@onready var panel_info = $"Panel"
@onready var scene_title = $"Panel/Scene title"
@onready var scene_description = $"Panel/Description"

func _ready() -> void:
	panel_info.visible = false
	scene_title.text = title
	scene_description.text = description
	
	$".".tooltip_text = tool_tip
	
	loading_modal.visible = false
	shader_mat.set_shader_parameter("line_thickness", 0.0)
	
func _on_pressed() -> void:
	if PlayerGlobalScript.isModalOpen == false:
		loading_modal.visible = true
		loading_modal.load(scene_path)

func _on_mouse_entered() -> void:
	if PlayerGlobalScript.isModalOpen == false:
		panel_info.visible = true
		shader_mat.set_shader_parameter("line_thickness", 5.0)

func _on_mouse_exited() -> void:
	if PlayerGlobalScript.isModalOpen == false:
		panel_info.visible = false
		shader_mat.set_shader_parameter("line_thickness", 0.0)
