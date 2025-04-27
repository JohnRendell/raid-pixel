extends Node

@onready var login_modal = $"CanvasLayer/Log in Modal"

#buttons
@onready var play_btn = $"CanvasLayer/UI Buttons/Play Button"

#login modal components
@onready var warning_text = $"CanvasLayer/Log in Modal/Warning Text"
@onready var login_proceed_btn = $"CanvasLayer/Log in Modal/Proceed Button"
@onready var username_input = $"CanvasLayer/Log in Modal/Username Input"
@onready var password_input = $"CanvasLayer/Log in Modal/Password Input"

#validation modal
@onready var validation_modal = $"CanvasLayer/Validation Modal"

func _ready() -> void:
	warning_text.text = ""
	validation_modal.visible = false
	
	play_btn.connect("pressed", func (): login_modal.modal_status(true))
	login_proceed_btn.connect("pressed", proceed_login)
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if not socket_status == "Connected":
		validation_modal.visible = false

func proceed_login():
	if not username_input.text or not password_input.text:
		warning_text.text = "Fields are empty!"
	else:
		validation_modal.visible = true
		
		var account_validate_result = await ServerFetch.send_post_request(ServerFetch.backend_url + "accountRoute/validateAccount", { "username": username_input.text, "password": password_input.text })
		
		if account_validate_result["status"] == "Account found":
			print("Going to the lobby")

		warning_text.text = "" if account_validate_result["status"] == "Account found" else "Username or Password Incorrect"
		print(account_validate_result["status"])
		validation_modal.visible = false
