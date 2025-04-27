extends Node

@onready var login_modal = $"CanvasLayer/Log in Modal"

#buttons
@onready var play_btn = $"CanvasLayer/UI Buttons/Play Button"

func _ready() -> void:
	play_btn.connect("button_down", func (): login_modal.modal_status(true))
