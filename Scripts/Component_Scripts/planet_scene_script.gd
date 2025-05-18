extends Control

@onready var planet_button = $"."
@onready var shader_mat = planet_button.material

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
	planet_button.tooltip_text = tool_tip
	
	loading_modal.visible = false
	shader_mat.set_shader_parameter("line_thickness", 0.0)
	
	planet_button.connect("pressed", planet_click)
	planet_button.connect("mouse_entered", planet_hover_in)
	planet_button.connect("mouse_exited", planet_hover_out)
	
func planet_click():
	if PlayerGlobalScript.isModalOpen == false and PlayerGlobalScript.current_modal_open == false:
		loading_modal.visible = true
		loading_modal.load(scene_path)

func planet_hover_in():
	if PlayerGlobalScript.isModalOpen == false and PlayerGlobalScript.current_modal_open == false:
		panel_info.visible = true
		shader_mat.set_shader_parameter("line_thickness", 5.0)

func planet_hover_out():
	if PlayerGlobalScript.isModalOpen == false and PlayerGlobalScript.current_modal_open == false:
		panel_info.visible = false
		shader_mat.set_shader_parameter("line_thickness", 0.0)
