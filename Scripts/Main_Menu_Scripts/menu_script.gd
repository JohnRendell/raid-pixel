extends Node

@onready var login_modal = $"CanvasLayer/Log in Modal"

#buttons
@onready var play_btn = $"CanvasLayer/UI Buttons/Play Button"

#login modal components
@onready var warning_text = $"CanvasLayer/Log in Modal/Warning Text"
@onready var login_proceed_btn = $"CanvasLayer/Log in Modal/Proceed Button"
@onready var username_input = $"CanvasLayer/Log in Modal/Username Input"
@onready var password_input = $"CanvasLayer/Log in Modal/Password Input"
@onready var guest_proceed_btn = $"CanvasLayer/Log in Modal/Guest Button Log in"

#validation modal
@onready var validation_modal = $"CanvasLayer/Validation Modal"

#loading modal
@onready var loading_modal = $"CanvasLayer/Loading Interface"

func _ready() -> void:
	warning_text.text = ""
	validation_modal.visible = false
	loading_modal.visible = false
	
	play_btn.connect("pressed", func (): login_modal.modal_status(true))
	guest_proceed_btn.connect("pressed", login_as_guest)
	login_proceed_btn.connect("pressed", proceed_login)
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if not socket_status == "Connected":
		validation_modal.visible = false

func login_as_guest():
	PlayerGlobalScript.player_in_game_name = "Guest_%s" % [string_generator()]
	PlayerGlobalScript.player_game_id = "GameID_%s" % [string_generator()]
	
	loading_modal.visible = true
	loading_modal.load("res://Scenes/lobby_scene.tscn")
	
func string_generator():
	var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
	"m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
	var nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	
	var randomNum = RandomNumberGenerator.new()
	var result : String = ""
	
	for i in range(2):
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
			loading_modal.visible = true
			
			PlayerGlobalScript.player_in_game_name = account_validate_result["inGameName"]
			PlayerGlobalScript.player_game_id = "GameID_%s" % [string_generator()]
			
			loading_modal.load("res://Scenes/lobby_scene.tscn")

		username_input_style.border_color = "black" if account_validate_result["status"] == "Account found" else "red"
		password_input_style.border_color = "black" if account_validate_result["status"] == "Account found" else "red"
		
		warning_text.text = "" if account_validate_result["status"] == "Account found" else "Username or Password Incorrect"
		validation_modal.visible = false
