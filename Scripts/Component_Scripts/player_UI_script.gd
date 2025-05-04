extends Global_Message

@onready var coordinate_label = $Coordinates
@onready var global_message_modal = $"Global Messages"
@onready var playerCount = $"Player Count"
@onready var logout_btn = $"Setting Modal/Log out Button"
@onready var loading_modal = $"Loading Modal"
@onready var validation_modal = $"Validation Modal"
@onready var diamond_count_label = $"Diamond Panel/Diamond Count"
@onready var player_profile = $"Profile"
@onready var http_request = $"HTTPRequest"

func _ready() -> void:
	logout_btn.connect("pressed", going_log_out)
	
	global_message_modal.visible = false
	validation_modal.visible = false
	
	timer_label.visible = false
	loading_modal.visible = false
	
	#load profile image
	var url = PlayerGlobalScript.player_profile
	http_request.request(url)
		
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
	if FileAccess.file_exists("user://login_data.json"):
		DirAccess.remove_absolute("user://login_data.json")
		
	PlayerGlobalScript.isLoggedOut = true
	validation_modal.visible = true
	gameData.player_logout()
	
	if PlayerGlobalScript.player_account_type == "Guest":
		await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/deleteAccountGuest", { "username": PlayerGlobalScript.player_username, "login_token": PlayerGlobalScript.player_UUID })
	
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
	PlayerGlobalScript.player_UUID = ""
	PlayerGlobalScript.player_account_type = ""
	PlayerGlobalScript.player_username = ""
	PlayerGlobalScript.player_diamond = 0
	
	loading_modal.visible = true
	loading_modal.load("res://Scenes/main_menu.tscn")

func _on_timer_timeout() -> void:
	timer_label.visible = false
	global_message_input.editable = true
	
	await get_tree().process_frame
	global_message_input.grab_focus()
	
func _on_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var image = Image.new()
		var err = image.load_png_from_buffer(body)
		
		if err == OK:
			var texture = ImageTexture.create_from_image(image)
			player_profile.texture = texture
		else:
			print("Failed to load image from buffer:", err)
	else:
		print("HTTP request failed with code:", response_code)
