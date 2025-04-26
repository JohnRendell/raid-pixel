extends Node

@onready var connection_panel = $"Background Panel"
@onready var connection_label = $"Background Panel/Panel/Status Label"
@onready var sprite_anim = $"Background Panel/Panel/Sprite/AnimationPlayer"
@onready var retry_button = $"Background Panel/Panel/Reconnect Button"

var isDisconnect = false

func _ready() -> void:
	connection_panel.visible = true
	sprite_anim.play("Connecting_Anim")
	retry_button.visible = false
	
	retry_button.connect("button_down", WebsocketsConnection.retry_connection)
	
func _process(_delta: float) -> void:
	var socket_status = WebsocketsConnection.socket_connection_status
	
	if socket_status == "Connecting to server":
		connection_label.text = socket_status + "..."
		sprite_anim.play("Connecting_Anim")
	
	elif socket_status == "Connected":
		connection_label.text = socket_status
		
	else:
		connection_label.text = socket_status
		
		if isDisconnect == false:
			sprite_anim.play("Disconnected_Anim")
		_on_animation_player_animation_finished("Disconnected_Anim")
	
	retry_button.visible = false if socket_status == "Connected" or socket_status == "Connecting to server" else true
	connection_panel.visible = false if socket_status == "Connected" else true
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Disconnected_Anim":
		isDisconnect = true
		sprite_anim.play("Disconnected_Anim_con")
