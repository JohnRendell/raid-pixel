extends Node

@onready var connection_panel = $"."
@onready var connection_label = $"Background Panel/Panel/Status Label"
@onready var sprite_anim = $"Background Panel/Panel/Sprite/AnimationPlayer"
@onready var retry_button = $"Background Panel/Panel/Reconnect Button"

var isDisconnect = false

func _ready() -> void:
	PlayerGlobalScript.isLoggedOut = false
	
	if WebsocketsConnection.socket_connection_status == "Disconnected":
		WebsocketsConnection.retry_connection()
		
	connection_panel.visible = true
	sprite_anim.play("Connecting_Anim")
	retry_button.visible = false
	
	retry_button.connect("button_down", retry_socket)
	
func retry_socket():
	PlayerGlobalScript.current_modal_open = false
	PlayerGlobalScript.isModalOpen = false
	WebsocketsConnection.retry_connection()
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if socket_status == "Connecting to server" or socket_status == "Reconnecting":
		sprite_anim.play("Connecting_Anim")
	
	elif socket_status == "Disconnected" and isDisconnect == false:
		sprite_anim.play("Disconnected_Anim")
		isDisconnect = true
	
	connection_label.text = socket_status if socket_status == "Connected" else socket_status + "..."
	retry_button.visible = false if socket_status == "Connected" or socket_status == "Connecting to server" or socket_status == "Reconnecting" else true
	
	if PlayerGlobalScript.isLoggedOut or socket_status == "Connected":
		connection_panel.visible = false
	else:
		connection_panel.visible = true
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Disconnected_Anim":
		sprite_anim.play("Disconnected_Anim_con")
