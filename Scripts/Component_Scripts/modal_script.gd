extends Node

@onready var modal_panel = $"."
@onready var modal_close_button = $"Panel Container/Close Button"
@onready var modal_label = $"Panel Container/Modal Label"
@onready var modal_anim = $"AnimationPlayer"
@export var modal_open_button: Button

@export var label = "Label of the modal"

var isOpen = false
var isAnimDone = false

func _ready() -> void:
	modal_open_button.focus_mode = Control.FOCUS_NONE
	modal_close_button.focus_mode = Control.FOCUS_NONE

	modal_panel.visible = false
	modal_open_button.connect("pressed", func (): modal_status(true))
	modal_close_button.connect("pressed", func (): modal_status(false))
	modal_label.text = label
	
func modal_status(status: bool):
	isAnimDone = false
	
	if status:
		if PlayerGlobalScript.current_modal_open == false:
			modal_panel.visible = true
			modal_anim.play("pop_modal")
			isOpen = true
			PlayerGlobalScript.isModalOpen = isOpen
			PlayerGlobalScript.current_modal_open = isOpen
	else:
		modal_anim.play_backwards("pop_modal")
		isOpen = false
		PlayerGlobalScript.isModalOpen = isOpen
		PlayerGlobalScript.current_modal_open = isOpen
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if socket_status == "Disconnected":
		modal_panel.visible = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pop_modal":
		modal_panel.visible = isOpen
		isAnimDone = isOpen
