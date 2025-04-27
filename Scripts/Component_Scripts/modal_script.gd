extends Node

@onready var modal_panel = $"."
@onready var modal_close_button = $"Background Panel/Panel/Close Button"
@onready var modal_label = $"Background Panel/Panel/Modal Label"

@export var label = "Label of the modal"

func _ready() -> void:
	modal_panel.visible = false
	modal_close_button.connect("pressed", func (): modal_status(false))
	modal_label.text = label
	
func modal_status(status: bool):
	modal_panel.visible = status
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if socket_status == "Disconnected":
		modal_panel.visible = false
