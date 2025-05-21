extends Global_Message

@onready var coordinate_label = $Coordinates
@onready var global_message_modal = $"Global Messages"
@onready var playerCount = $"Player Count"
@onready var loading_modal = $"Loading Modal"
@onready var validation_modal = $"Validation Modal"
@onready var diamond_count_label = $"Diamond Panel/Diamond Count"
@onready var player_profile = $"Profile"
@onready var http_request = $"HTTPRequest"
@onready var current_player_scene_button = $"Show Players button"

#setting modal contents
@onready var logout_btn = $"Setting Modal/Panel/Log out Button"
@onready var surrender_btn = $"Setting Modal/Panel/Surrender Button"

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
@onready var guest_animation = $"Guest Connect Account Panel/Guest Animation Player"

#profile panel contents
@onready var player_in_game_name_label = $"Profile Modal/Panel/In Game Name Label"
@onready var player_gameID_label = $"Profile Modal/Panel/Game ID Label"
@onready var player_description_label = $"Profile Modal/Panel/Description Label"
@onready var player_profile_view = $"Profile Modal/Panel/Profile View"

@onready var warning_text = $"Profile Modal/Panel/Warning Text"

@onready var profile_preview = $"Profile Modal/Panel/Profile Preview"
@onready var in_game_name_input =  $"Profile Modal/Panel/In Game Name Input"
@onready var description_input =  $"Profile Modal/Panel/Description Input"
@onready var change_profile_button = $"Profile Modal/Panel/Change Profile Button"
@onready var fileDialog_panel = $"Profile Modal/File Panel"
@onready var fileDialog = $"Profile Modal/File Panel/FileDialog"

@onready var edit_profile_button = $"Profile Modal/Panel/Edit Button"
@onready var cancel_edit_profile_button = $"Profile Modal/Panel/Cancel Edit Button"
@onready var save_edit_profile_button =  $"Profile Modal/Panel/Save Edit Button"

#for passing data
var prev_count = ""
var prev_coordinates = Vector2.ZERO
var prev_diamond = 0

var profile_base64: String

#for components classes
var player_profile_class = PlayerProfile.new()
var game_data_class = GameData.new()

func _ready() -> void:
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
	
	guestAccountButton.focus_mode = Control.FOCUS_NONE
	guestAccountButton.connect("pressed", func(): status_panel(true, guest_connect_account_panel))
	guest_warning_panel_button.connect("pressed", func(): guest_warning_panel.visible = false)
	guest_back_button.connect("pressed", func(): status_panel(false, guest_connect_account_panel))
	guest_confirm_button.connect("pressed", upgrade_account)
	
	#hide all inputs stuff on player profile
	in_game_name_input.visible = false
	description_input.visible = false
	warning_text.visible = false
	
	#for profile picture inputs
	fileDialog_panel.visible = false
	fileDialog.visible = false
	fileDialog.filters = ["*.png", "*.jpg", "*.jpeg"]
	
	save_edit_profile_button.visible = false
	cancel_edit_profile_button.visible = false
	edit_profile_button.visible = true
	change_profile_button.visible = false
	
	change_profile_button.connect("pressed", open_file_Dialog)
	cancel_edit_profile_button.connect("pressed", func(): player_profile_class.edit_profile_status(false, in_game_name_input, description_input, cancel_edit_profile_button, save_edit_profile_button, edit_profile_button, player_in_game_name_label, player_description_label, change_profile_button, profile_preview, player_profile_view))
	edit_profile_button.connect("pressed", func(): player_profile_class.edit_profile_status(true, in_game_name_input, description_input, cancel_edit_profile_button, save_edit_profile_button, edit_profile_button, player_in_game_name_label, player_description_label, change_profile_button, profile_preview, player_profile_view))
	save_edit_profile_button.connect("pressed", save_profile_edit)
	
	#for setting modal, to check if player is in game.
	await get_tree().process_frame
	var current_scene = PlayerGlobalScript.current_scene
	
	logout_btn.connect("pressed", log_out_action)
	logout_btn.visible = current_scene.to_upper() == "LOBBY"
	surrender_btn.visible = not current_scene.to_upper() == "LOBBY"
		
	var data = await player_profile_class.get_player_data(http_request)
	if data["status"] == "Finished":
		in_game_name_input.text = data["inGameName"]
		description_input.text = data["description"]
		
		var count = await game_data_class.get_player_count()
		playerCount.text = "Active player/s: %s" % [count]
		
func log_out_action():
	game_data_class.player_logout(validation_modal, loading_modal, PlayerGlobalScript.player_game_id, PlayerGlobalScript.player_username)
	
func open_file_Dialog():
	fileDialog.visible = true
	fileDialog_panel.visible = true
	
func save_profile_edit():
	var regex = RegEx.new()
	regex.compile("\\s")
	
	validation_modal.visible = true
	
	var inGameName_input_style = in_game_name_input.get_theme_stylebox("normal")
	var description_input_style = description_input.get_theme_stylebox("normal")
	
	if not in_game_name_input.text:
		inGameName_input_style.border_color = "red"
		
		warning_text.visible = true
		warning_text.text = "In Game Name must be inputted."
		validation_modal.visible = false
		
	elif len(in_game_name_input.text) <= 4:
		inGameName_input_style.border_color = "red"
		description_input_style.border_color = "black"
		
		warning_text.visible = true
		warning_text.text = "In Game Name too short, five characters minimum."
		validation_modal.visible = false
		
	elif regex.search(in_game_name_input.text):
		inGameName_input_style.border_color = "red"
		
		warning_text.visible = true
		warning_text.text = "In Game Name cannot contain spaces."
		validation_modal.visible = false

	else:
		warning_text.visible = false
		
		var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "playerInformation/modifyPlayerData", { "username": PlayerGlobalScript.player_username, "inGameName": in_game_name_input.text, "description": description_input.text, "profile": profile_base64 })
		
		if result.has("status") and result["status"] == "Success":
			validation_modal.visible = false
			
			PlayerGlobalScript.player_in_game_name = result["inGameName"]
			player_profile_class.description_profile = result["description"]
			
			if result["profile"]:
				PlayerGlobalScript.player_profile = result["profile"]
				
				var url = PlayerGlobalScript.player_profile
				http_request.request(url)
			
			profile_base64 = ""
			
			player_profile_class.edit_profile_status(false, in_game_name_input, description_input, cancel_edit_profile_button, save_edit_profile_button, edit_profile_button, player_in_game_name_label, player_description_label, change_profile_button, profile_preview, player_profile_view)
			
			SocketClient.send_data({
				"Socket_Name": "ModifyProfile",
				"Player_GameID": PlayerGlobalScript.player_game_id,
				"Player_inGameName": PlayerGlobalScript.player_in_game_name
			})
	
func status_panel(status: bool, panel: Panel):
	if status:
		if not PlayerGlobalScript.current_modal_open and not PlayerGlobalScript.isModalOpen:
			panel.visible = status
			guest_animation.play("pop")
	else:
		guest_animation.play_backwards("pop")
	PlayerGlobalScript.isModalOpen = status
	PlayerGlobalScript.current_modal_open = status
	
func upgrade_account():
	if not PlayerGlobalScript.current_modal_open and not PlayerGlobalScript.isModalOpen:
		PlayerGlobalScript.current_modal_open = true
		PlayerGlobalScript.isModalOpen = true
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
	player_profile_class.render_player_profile_data(player_in_game_name_label, player_gameID_label, player_description_label)
	
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
			profile_preview.texture = texture
		else:
			print("Failed to load image from buffer:", err)
	else:
		print("HTTP request failed with code:", response_code)

func _on_guest_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pop":
		if PlayerGlobalScript.isModalOpen == false:
			guest_connect_account_panel.visible = false

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	var error = image.load(path)
	
	if error == OK:
		var texture = ImageTexture.create_from_image(image)
		profile_preview.texture = texture
		
		var byte_array = image.save_png_to_buffer()
		var base64_string = Marshalls.raw_to_base64(byte_array)

		profile_base64 = base64_string
	else:
		push_error("Failed to load image.")

func _on_file_dialog_canceled() -> void:
	fileDialog_panel.visible = false

func _on_file_dialog_confirmed() -> void:
	fileDialog_panel.visible = false
