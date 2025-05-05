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

#for guest stuff
@onready var guestAccountButton = $"Guest Account connect button"
@onready var guest_warning_panel = $"Guest Warning Panel"
@onready var guest_warning_panel_button = $"Guest Warning Panel/Panel/Understand button"
@onready var guest_connect_account_panel = $"Guest Connect Account Panel"
@onready var guest_connect_success_panel = $"Connect Account Success Panel"
@onready var guest_connect_success_panel_btn = $"Connect Account Success Panel/Panel/Ok button"

#inputs for account guest connect
@onready var guest_password_input = $"Guest Connect Account Panel/Panel/Password Input"
@onready var guest_confirm_password_input = $"Guest Connect Account Panel/Panel/Retype Password Input"
@onready var guest_confirm_button = $"Guest Connect Account Panel/Panel/Confirm button"
@onready var guest_back_button = $"Guest Connect Account Panel/Panel/Cancel Button"
@onready var guest_warning_text = $"Guest Connect Account Panel/Panel/Warning text"

#for player profile contents
@onready var player_in_game_name_label = $"Profile Modal/In Game Name Label"
@onready var player_gameID_label = $"Profile Modal/Game ID Label"
@onready var player_profile_view = $"Profile Modal/Profile View"
@onready var player_description_label = $"Profile Modal/Description Label"

#for passing data
var prev_count = ""
var prev_IGN = ""
var prev_gameID = ""
var prev_description = ""
var prev_diamond = 0
var prev_coordinates = Vector2.ZERO

#for profile
var description_profile = ""

func _ready() -> void:
	logout_btn.connect("pressed", going_log_out)
	guest_connect_success_panel_btn.connect("pressed", func(): status_panel(false, guest_connect_success_panel))
	
	global_message_modal.visible = false
	validation_modal.visible = false
	guest_connect_account_panel.visible = false
	guest_connect_success_panel.visible = false
	
	timer_label.visible = false
	loading_modal.visible = false
	guest_warning_text.visible = false
	
	guest_warning_panel.visible = true if PlayerGlobalScript.player_account_type == "Guest" else false
	guestAccountButton.visible =  true if PlayerGlobalScript.player_account_type == "Guest" else false
	
	guestAccountButton.connect("pressed", func(): status_panel(true, guest_connect_account_panel))
	guest_warning_panel_button.connect("pressed", func(): guest_warning_panel.visible = false)
	guest_back_button.connect("pressed", func(): status_panel(false, guest_connect_account_panel))
	guest_confirm_button.connect("pressed", upgrade_account)
	
	get_player_data()
	
func get_player_data():
	var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "playerInformation/playerData", { "username": PlayerGlobalScript.player_username })
	
	if result["status"] == "Success":
		PlayerGlobalScript.player_profile = result["profile"]
		PlayerGlobalScript.player_diamond = result["diamond"]
		PlayerGlobalScript.player_in_game_name = result["inGameName"]
		description_profile = result["description"]
	
		#load profile image
		var url = PlayerGlobalScript.player_profile
		http_request.request(url)
	
func status_panel(status: bool, panel: Panel):
	panel.visible = status
	PlayerGlobalScript.isModalOpen = status
	PlayerGlobalScript.current_modal_open = status
	
func upgrade_account():
	validation_modal.visible = true
	
	#for inputs
	if not guest_password_input.text or not guest_confirm_password_input.text:
		guest_warning_text.visible = true
		guest_warning_text.text = "Fields cannot be empty!."
		
		guest_password_input.get_theme_stylebox("normal").border_color = "red"
		guest_confirm_password_input.get_theme_stylebox("normal").border_color = "red"
	
	elif len(guest_password_input.text) <= 4:
		guest_warning_text.visible = true
		guest_warning_text.text = "Password should be 5 characters above."
		
		guest_password_input.get_theme_stylebox("normal").border_color = "red"
		
	elif guest_password_input.text != guest_confirm_password_input.text:
		guest_warning_text.visible = true
		guest_warning_text.text = "Password should match."
		
		guest_password_input.get_theme_stylebox("normal").border_color = "red"
		guest_confirm_password_input.get_theme_stylebox("normal").border_color = "red"
		
	else:
		var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/connectAccount", { "username": PlayerGlobalScript.player_username, "password": guest_password_input.text })
		
		if result["status"] == "Success":
			guest_connect_account_panel.visible = false
			guest_connect_success_panel.visible = true
			
			PlayerGlobalScript.player_account_type = result["accountType"]
		else:
			guest_warning_text.text = result["status"]
			
		guest_password_input.get_theme_stylebox("normal").border_color = "black"
		guest_confirm_password_input.get_theme_stylebox("normal").border_color = "black"
		
	validation_modal.visible = false
	guestAccountButton.visible =  true if PlayerGlobalScript.player_account_type == "Guest" else false
		
func _process(_delta: float) -> void:
	if prev_IGN != PlayerGlobalScript.player_in_game_name:
		prev_IGN = PlayerGlobalScript.player_in_game_name
		player_in_game_name_label.text = prev_IGN
		
	if prev_gameID != PlayerGlobalScript.player_game_id:
		prev_gameID = PlayerGlobalScript.player_game_id
		player_gameID_label.text = prev_gameID
		
	if prev_description != description_profile:
		prev_description = description_profile
		player_description_label.text = prev_description
	
	var count = gameData.renderPlayerCount()
	if prev_count != count:
		prev_count = count
		playerCount.text = "Active player/s: %s" % [count]
		
	if prev_diamond != PlayerGlobalScript.player_diamond:
		prev_diamond = PlayerGlobalScript.player_diamond
		diamond_count_label.text = str(PlayerGlobalScript.player_diamond)
	
	if prev_coordinates != Vector2(PlayerGlobalScript.player_pos_X, PlayerGlobalScript.player_pos_Y):
		prev_coordinates = Vector2(PlayerGlobalScript.player_pos_X, PlayerGlobalScript.player_pos_Y)
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
	gameData.player_logout(prev_gameID)
	
	if PlayerGlobalScript.player_account_type == "Guest":
		await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/deleteAccountGuest", { "username": PlayerGlobalScript.player_username, "login_token": PlayerGlobalScript.player_UUID })
	
	await get_tree().create_timer(1.0).timeout

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
			player_profile_view.texture = texture
		else:
			print("Failed to load image from buffer:", err)
	else:
		print("HTTP request failed with code:", response_code)
