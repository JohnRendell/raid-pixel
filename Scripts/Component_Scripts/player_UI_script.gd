extends Global_Message

@onready var coordinate_label = $Coordinates
@onready var global_message_modal = $"Global Messages"

func _ready() -> void:
	global_message_modal.visible = false

func _process(_delta: float) -> void:
	coordinate_label.text = "Player posX: " + str("%.2f" % PlayerGlobalScript.player_pos_X) + "\nPlayer posY: " + str("%.2f" % PlayerGlobalScript.player_pos_Y)
	
	var data = SocketClient.socket_data
	message_render_display(data)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("global_message"):
		if global_message_modal.visible:
			message_append_on_container()
			PlayerGlobalScript.isModalOpen = false
			global_message_modal.visible = false
			global_message_input.text = ""
		else:
			global_message_modal.visible = true
			PlayerGlobalScript.isModalOpen = true
			
			await get_tree().process_frame
			global_message_input.grab_focus()
