extends Global_Message

@onready var coordinate_label = $Coordinates
@onready var global_message_modal = $"Global Messages"
@onready var playerCount = $"Player Count"
@onready var logout_btn = $"Setting Modal/Log out Button"
@onready var loading_modal = $"Loading Modal"
@onready var validation_modal = $"Validation Modal"
@onready var diamond_count_label = $"Diamond Panel/Diamond Count"

func _ready() -> void:
	logout_btn.connect("pressed", going_log_out)
	
	global_message_modal.visible = false
	validation_modal.visible = false
	
	timer_label.visible = false
	loading_modal.visible = false
		
func _process(_delta: float) -> void:
	playerCount.text = "Active player/s: %s" % [gameData.renderPlayerCount()]
	diamond_count_label.text = str(PlayerGlobalScript.player_diamond)
	
	coordinate_label.text = "Player posX: " + str("%.2f" % PlayerGlobalScript.player_pos_X) + "\nPlayer posY: " + str("%.2f" % PlayerGlobalScript.player_pos_Y)
	
	message_render_display()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("global_message"): #pressing enter
		if global_message_modal.visible:
			message_append_on_container()

			PlayerGlobalScript.isModalOpen = false
			PlayerGlobalScript.current_modal_open = false
			global_message_modal.visible = false
			global_message_input.text = ""
			timer.wait_time = 1.0
		else:
			if PlayerGlobalScript.current_modal_open == false:
				global_message_modal.visible = true
				PlayerGlobalScript.isModalOpen = true
				PlayerGlobalScript.current_modal_open = true
				
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

func going_log_out():
	PlayerGlobalScript.isLoggedOut = true
	validation_modal.visible = true
	gameData.player_logout()
	
	await get_tree().create_timer(1.0).timeout

	SocketClient.isConnected = false
	WebsocketsConnection.socket_connection_status = ""
	WebsocketsConnection.socket_data = {}
	
	# Disconnect WebSocket
	WebsocketsConnection.disconnect_to_socket()
	
	await get_tree().create_timer(1.0).timeout

	PlayerGlobalScript.isModalOpen = false
	PlayerGlobalScript.current_modal_open = false
	PlayerGlobalScript.player_in_game_name = ""
	PlayerGlobalScript.player_game_id = ""
	
	loading_modal.visible = true
	loading_modal.load("res://Scenes/main_menu.tscn")

func _on_timer_timeout() -> void:
	timer_label.visible = false
	global_message_input.editable = true
	
	await get_tree().process_frame
	global_message_input.grab_focus()
