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
@onready var off_world_button = $"Off World button"
@onready var current_player_scene_button = $"Show Players button"

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

#profile panel contents
@onready var player_in_game_name_label = $"Profile Modal/In Game Name Label"
@onready var player_gameID_label = $"Profile Modal/Game ID Label"
@onready var player_description_label = $"Profile Modal/Description Label"
@onready var player_profile_view = $"Profile Modal/Profile View"

@onready var warning_text = $"Profile Modal/Warning Text"

@onready var in_game_name_input =  $"Profile Modal/In Game Name Input"
@onready var description_input =  $"Profile Modal/Description Input"

@onready var edit_profile_button = $"Profile Modal/Edit Button"
@onready var cancel_edit_profile_button = $"Profile Modal/Cancel Edit Button"
@onready var save_edit_profile_button =  $"Profile Modal/Save Edit Button"

#other player's profile modal stuff
@onready var active_player_btn = $"Show Players button"
@onready var player_list_container = $"Active Player Modal/Player's list container"
@onready var player_name_list = $"Active Player Modal/Player Name"
@onready var player_info_panel = $"Player's Info Panel"
@onready var jplayer_name_label = $"Player's Info Panel/Player In Game Name"
@onready var jplayer_description_label = $"Player's Info Panel/Description"
@onready var jplayer_profile = $"Player's Info Panel/Player profile"
@onready var jplayer_gameID = $"Player's Info Panel/Player Game ID"
@onready var j_http_request = $"player_list_HTTPRequest"

#for passing data
var prev_count = ""
var prev_coordinates = Vector2.ZERO
var prev_diamond = 0

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
	
	guestAccountButton.connect("pressed", func(): status_panel(true, guest_connect_account_panel))
	guest_warning_panel_button.connect("pressed", func(): guest_warning_panel.visible = false)
	guest_back_button.connect("pressed", func(): status_panel(false, guest_connect_account_panel))
	guest_confirm_button.connect("pressed", upgrade_account)
	
	#hide all inputs stuff on player profile
	in_game_name_input.visible = false
	description_input.visible = false
	warning_text.visible = false
	
	save_edit_profile_button.visible = false
	cancel_edit_profile_button.visible = false
	edit_profile_button.visible = true
	
	cancel_edit_profile_button.connect("pressed", func(): player_profile_class.edit_profile_status(false, in_game_name_input, description_input, cancel_edit_profile_button, save_edit_profile_button, edit_profile_button, player_in_game_name_label, player_description_label))
	edit_profile_button.connect("pressed", func(): player_profile_class.edit_profile_status(true, in_game_name_input, description_input, cancel_edit_profile_button, save_edit_profile_button, edit_profile_button, player_in_game_name_label, player_description_label))
	save_edit_profile_button.connect("pressed", save_profile_edit)
	
	player_info_panel.visible = false
		
	var data = await player_profile_class.get_player_data(http_request)
	if data["status"] == "Finished":
		in_game_name_input.text = data["inGameName"]
		description_input.text = data["description"]
		
		logout_btn.connect("pressed", log_out_action)
		
		var count = await game_data_class.get_player_count()
		playerCount.text = "Active player/s: %s" % [count]
		
	#for button and other stuff
	var current_scene = PlayerGlobalScript.current_scene
	off_world_button.visible = false if current_scene.to_upper() == "MAP_SCENE" else true
	off_world_button.connect("pressed", going_off_world)
	
	coordinate_label.visible = false if current_scene.to_upper() == "MAP_SCENE" else true
	current_player_scene_button.visible = false if current_scene.to_upper() == "MAP_SCENE" else true
	
	active_player_btn.connect("pressed", load_player_list)
	
func load_player_list():
	var list = GetPlayerInfo.active_player_dic
	
	for child in player_list_container.get_children():
		print(list)
		print(child.name)
		if child.name not in list.keys():
			child.queue_free()
	
	for player in list:
		if not player_list_container.has_node(player):
			var player_gameID = list[player]["Player_GameID"]
			
			var player_btn = player_name_list.duplicate()
			player_btn.name = player
			player_btn.text = player
			player_btn.visible = true
			player_btn.connect("mouse_entered", func(): get_player_data(player, player_gameID))
			player_btn.connect("mouse_exited", func(): player_info_panel.visible = false)
			player_list_container.add_child(player_btn)

func get_player_data(username, playerGameID):
	player_info_panel.visible = true
	var result = await GetPlayerInfo.get_player_info(username)
	
	if result.has("status") and result["status"] == "Success":
		jplayer_name_label.text = result["player_IGN"]
		jplayer_description_label.text = result["player_description"]
		jplayer_gameID.text = playerGameID
		j_http_request.request(result["player_profile"])
		
func going_off_world():
	SocketClient.send_data({
		"Socket_Name": "going_offWorld",
		"Player_GameID": PlayerGlobalScript.player_game_id
	})
	
	loading_modal.visible = true
	loading_modal.load("res://Scenes/map_scene.tscn")
		
func log_out_action():
	game_data_class.player_logout(validation_modal, loading_modal, PlayerGlobalScript.player_game_id, PlayerGlobalScript.player_username)
	
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
		
		var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "playerInformation/modifyPlayerData", { "username": PlayerGlobalScript.player_username, "inGameName": in_game_name_input.text, "description": description_input.text })
		
		if result.has("status") and result["status"] == "Success":
			validation_modal.visible = false
			
			PlayerGlobalScript.player_in_game_name = result["inGameName"]
			player_profile_class.description_profile = result["description"]
			
			player_profile_class.edit_profile_status(false, in_game_name_input, description_input, cancel_edit_profile_button, save_edit_profile_button, edit_profile_button, player_in_game_name_label, player_description_label)
			
			SocketClient.send_data({
				"Socket_Name": "ModifyProfile",
				"Player_GameID": PlayerGlobalScript.player_game_id,
				"Player_inGameName": PlayerGlobalScript.player_in_game_name
			})
	
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
		else:
			print("Failed to load image from buffer:", err)
	else:
		print("HTTP request failed with code:", response_code)


func _on_player_list_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var image = Image.new()
		var err = image.load_png_from_buffer(body)
		
		if err == OK:
			var texture = ImageTexture.create_from_image(image)
			jplayer_profile.texture = texture
		else:
			print("Failed to load image from buffer:", err)
	else:
		print("HTTP request failed with code:", response_code)
