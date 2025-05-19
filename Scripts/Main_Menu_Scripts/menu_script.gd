extends Node

@onready var login_modal = $"CanvasLayer/Log in Modal"

#login modal components
@onready var warning_text = $"CanvasLayer/Log in Modal/Panel/Warning Text"
@onready var login_proceed_btn = $"CanvasLayer/Log in Modal/Panel/Proceed Button"
@onready var username_input = $"CanvasLayer/Log in Modal/Panel/Username Input"
@onready var password_input = $"CanvasLayer/Log in Modal/Panel/Password Input"
@onready var guest_proceed_btn = $"CanvasLayer/Log in Modal/Panel/Guest Button Log in"

#validation modal
@onready var validation_modal = $"CanvasLayer/Validation Modal"

#loading modal
@onready var loading_modal = $"CanvasLayer/Loading Interface"

#session expired modal
@onready var session_modal = $"CanvasLayer/Session Expired Panel"
@onready var session_modal_anim = $"CanvasLayer/Session Expired Panel/AnimationPlayer"

#online warn panel
@onready var online_warn = $"CanvasLayer/Online Panel Warning"
@onready var online_warn_button = $"CanvasLayer/Online Panel Warning/Panel/Okay Button"

func _ready() -> void:
	warning_text.text = ""
	session_modal.visible = false
	validation_modal.visible = false
	online_warn.visible = false
	
	guest_proceed_btn.connect("pressed", login_as_guest)
	login_proceed_btn.connect("pressed", proceed_login)
	online_warn_button.connect("pressed", func(): online_warn.visible = false)
	
	auto_login()
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if not socket_status == "Connected":
		validation_modal.visible = false

func login_as_guest():
	validation_modal.visible = true
	
	var createGuestAccount = await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/createGuestAccount", { "username": "Guest_%s" % [string_generator(2)] })
	
	if createGuestAccount["status"] == "Success":
		PlayerGlobalScript.player_UUID = createGuestAccount["login_token"]
		PlayerGlobalScript.player_account_type = createGuestAccount["player_type"]
		PlayerGlobalScript.player_username = createGuestAccount["username"]

		PlayerGlobalScript.player_game_id = "GameID_%s" % [string_generator(2)]
		PlayerGlobalScript.isModalOpen = false
		PlayerGlobalScript.current_modal_open = false
		
		loading_modal.load("res://Scenes/lobby_scene.tscn")
	else:
		validation_modal.visible = false
		PlayerGlobalScript.isModalOpen = false
		PlayerGlobalScript.current_modal_open = false
		print("Guest account failed")
	
func string_generator(size: int):
	var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
	"m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
	var nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	
	var randomNum = RandomNumberGenerator.new()
	var result : String = ""
	
	for i in range(size):
		var char_index = randomNum.randi_range(0, len(letters) - 1)
		var num_index = randomNum.randi_range(0, len(nums) - 1)
		
		var temp_name = "%s%s" % [letters[char_index], nums[num_index]]
		result += temp_name
	
	return result

func proceed_login():
	var username_input_style = username_input.get_theme_stylebox("normal")
	var password_input_style = password_input.get_theme_stylebox("normal")
	
	if not username_input.text or not password_input.text:
		username_input_style.border_color = "red"
		password_input_style.border_color = "red"
		warning_text.text = "Fields are empty!"
	else:
		validation_modal.visible = true
		
		var account_validate_result = await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/validateAccount", { "username": username_input.text, "password": password_input.text })
		
		if account_validate_result["status"] == "Account found":
			if not account_validate_result["isOnline"]:
				PlayerGlobalScript.player_account_type = account_validate_result["player_type"]
				PlayerGlobalScript.player_UUID = account_validate_result["login_token"]
				PlayerGlobalScript.player_username = account_validate_result["username"]
		
				PlayerGlobalScript.player_game_id = "GameID_%s" % [string_generator(2)]
				PlayerGlobalScript.isModalOpen = false
				PlayerGlobalScript.current_modal_open = false
				
				save_username_local(account_validate_result["username"], account_validate_result["login_token"])
				loading_modal.load("res://Scenes/lobby_scene.tscn")
			else:
				online_warn.visible = true

		username_input_style.border_color = "black" if account_validate_result["status"] == "Account found" else "red"
		password_input_style.border_color = "black" if account_validate_result["status"] == "Account found" else "red"
		
		warning_text.text = "" if account_validate_result["status"] == "Account found" else "Username or Password Incorrect"
		validation_modal.visible = false
		
func auto_login():
	validation_modal.visible = true
	
	if FileAccess.file_exists("user://login_data.json"):
		var file = FileAccess.open("user://login_data.json", FileAccess.READ)
		var content = file.get_as_text()
		file.close()

		var parsed = JSON.parse_string(content)
		var current_unix = Time.get_unix_time_from_system()
		
		if typeof(parsed) == TYPE_DICTIONARY:
			if parsed["expiration"] > current_unix:
				var client_token = "Client_tokenID_%s" % [string_generator(5)]
				var account_validate_result = await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/auth_auto_login", { "username": parsed["player_username"], "login_token": parsed["login_token"], "client_token": { "username": parsed["player_username"], "token": client_token }})
		
				if account_validate_result["status"] == "Success":
					if account_validate_result["client_token_result"].status == "Accepted":
						PlayerGlobalScript.player_UUID = account_validate_result["UUID"]
						PlayerGlobalScript.player_account_type = account_validate_result["player_type"]
						PlayerGlobalScript.player_username = account_validate_result["username"]
						
						PlayerGlobalScript.player_game_id = "GameID_%s" % [string_generator(2)]
					
						PlayerGlobalScript.isModalOpen = false
						PlayerGlobalScript.current_modal_open = false
					
						loading_modal.load("res://Scenes/lobby_scene.tscn")
					else:
						online_warn.visible = true
				else:
					DirAccess.remove_absolute("user://login_data.json")
				
					session_modal.visible = true
					session_modal_anim.play("toast_anim")
			else:
				DirAccess.remove_absolute("user://login_data.json")
				
				session_modal.visible = true
				session_modal_anim.play("toast_anim")
				
func save_username_local(username, login_token):
	var now_unix = Time.get_unix_time_from_system()
	var future_unix = now_unix + (30 * 86400)

	#save user data for auto login
	if not FileAccess.file_exists("user://login_data.json"):
		var data = {
			"player_username": username,
			"expiration": future_unix,
			"login_token": login_token
		}

		var file = FileAccess.open("user://login_data.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
		file.close()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "toast_anim":
		session_modal.queue_free()
