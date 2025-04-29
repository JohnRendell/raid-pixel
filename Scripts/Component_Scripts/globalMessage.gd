class_name Global_Message
extends Control

@onready var global_message_input = $"Global Messages/LineEdit"
@onready var message_label = $"Global Messages/Display Messages/HBoxContainer/Message label"
@onready var message_container = $"Global Messages/Display Messages/HBoxContainer"

#for rendering message that will disappear after sometime
@onready var display_message_panel = $"Display Message Panel"

func message_append_on_container():
	if global_message_input.text:
		var message_clone = message_label.duplicate()
		message_clone.visible = true
		message_clone.text = PlayerGlobalScript.player_in_game_name + "(You): " + global_message_input.text
		message_container.add_child(message_clone)
		
		SocketClient.send_data({
			"Socket_Name": "GlobalMessage",
			"Sender": PlayerGlobalScript.player_in_game_name,
			"GameID": PlayerGlobalScript.player_game_id,
			"Message": global_message_input.text
		})
		
#TODO: fix this, the message from backend not able to receive on client.
func message_render_display(data):	
	if data:
		print(data)
	if typeof(data) == TYPE_DICTIONARY:
		if data.get("Socket_Name") == "GlobalMessage":
			var message_clone = message_label.duplicate()
			message_clone.visible = true
			
			var receiver = data.get("Receiver") + "(You)" if data.get("Receiver") == PlayerGlobalScript.player_in_game_name else data.get("Receiver")
			message_clone.text = receiver + ": " + data.get("Message")
