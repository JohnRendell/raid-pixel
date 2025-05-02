extends Node

@onready var modal_panel = $"."
@onready var modal_close_button = $"Background Panel/Panel/Close Button"
@onready var modal_label = $"Background Panel/Panel/Modal Label"
@export var modal_open_button: Button

@export var label = "Label of the modal"

func _ready() -> void:
	modal_panel.visible = false
	modal_open_button.connect("pressed", func (): modal_status(true))
	modal_close_button.connect("pressed", func (): modal_status(false))
	modal_label.text = label
	
func modal_status(status: bool):
	if status:
		if PlayerGlobalScript.current_modal_open == false:
			modal_panel.visible = status
			PlayerGlobalScript.isModalOpen = status
			PlayerGlobalScript.current_modal_open = status
	else:
		PlayerGlobalScript.current_modal_open = status
		modal_panel.visible = status
		PlayerGlobalScript.isModalOpen = status
		PlayerGlobalScript.current_modal_open = status
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if socket_status == "Disconnected":
		modal_panel.visible = false
