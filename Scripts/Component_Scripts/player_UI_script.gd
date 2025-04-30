extends Global_Message

@onready var coordinate_label = $Coordinates
@onready var global_message_modal = $"Global Messages"

func _ready() -> void:
	global_message_modal.visible = false
	timer_label.visible = false

func _process(_delta: float) -> void:
	coordinate_label.text = "Player posX: " + str("%.2f" % PlayerGlobalScript.player_pos_X) + "\nPlayer posY: " + str("%.2f" % PlayerGlobalScript.player_pos_Y)
	
	message_render_display()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("global_message"): #pressing enter
		if global_message_modal.visible:
			message_append_on_container()

			PlayerGlobalScript.isModalOpen = false
			global_message_modal.visible = false
			global_message_input.text = ""
			timer.wait_time = 1.0
		else:
			global_message_modal.visible = true
			PlayerGlobalScript.isModalOpen = true
			
			await get_tree().process_frame
			scroll_message_container.scroll_vertical = scroll_message_container.get_v_scroll_bar().max_value
			
			if isSend:
				timer.start()
				timer_label.visible = true
			else:
				timer_label.visible = false
				await get_tree().process_frame
				global_message_input.grab_focus()
				
			global_message_input.editable = !timer_label.visible


func _on_timer_timeout() -> void:
	timer_label.visible = false
	global_message_input.editable = true
	
	await get_tree().process_frame
	global_message_input.grab_focus()
