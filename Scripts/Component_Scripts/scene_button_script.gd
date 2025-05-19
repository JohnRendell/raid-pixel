extends Node

@export var scene_path: String
@export var loading_modal: Control

@onready var texture_btn_shader =  $".".material

func _ready() -> void:
	texture_btn_shader.set_shader_parameter("line_thickness", 0)

func _on_pressed() -> void:
	if not PlayerGlobalScript.current_modal_open and not PlayerGlobalScript.isModalOpen:
		loading_modal.visible = true
		loading_modal.load(scene_path)

func _on_mouse_entered() -> void:
	texture_btn_shader.set_shader_parameter("line_thickness", 2.0)

func _on_mouse_exited() -> void:
	texture_btn_shader.set_shader_parameter("line_thickness", 0)
