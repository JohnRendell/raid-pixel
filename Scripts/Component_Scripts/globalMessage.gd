class_name Global_Message
extends Control

@onready var global_message_input = $"Global Messages/LineEdit"
@onready var message_label = $"Global Messages/Display Messages/HBoxContainer/Message label"
@onready var message_container = $"Global Messages/Display Messages/HBoxContainer"
@onready var scroll_message_container = $"Global Messages/Display Messages"

#for rendering message that will disappear after sometime
@onready var display_message_panel = $"Display Message Panel/Display Container Box"

#a timer and label to wait for input
@onready var timer_label = $"Global Messages/Wait for input Label"
@onready var timer = $"Global Messages/Timer"

#for game data
var gameData = GameData.new()

var isSend = false

#this is for prev data to avoid receiving a bunch
var prev_data: Dictionary

func message_append_on_container():
	if global_message_input.text:		
		SocketClient.send_data({
			"Socket_Name": "GlobalMessage",
			"Sender": PlayerGlobalScript.player_in_game_name,
			"GameID": PlayerGlobalScript.player_game_id,
			"Message": global_message_input.text
		})
		isSend = true
		
func message_render_display():	
	var data = SocketClient.received_data()

	#sending global messages
	if data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "GlobalMessage":
		prev_data = data
		
		var receiver = data.get("Receiver") + "(You)" if data.get("Receiver") == PlayerGlobalScript.player_in_game_name else data.get("Receiver")
		var message_clone = message_label.duplicate()
		message_clone.visible = true
		
		message_clone.text = receiver + ": " + data.get("Message")
		message_container.add_child(message_clone)
		
		#remove old messages
		if display_message_panel.get_child_count() >= 5:
			var oldest = display_message_panel.get_child(0)
			oldest.queue_free()
		
		#add a new one
		var display_msg = message_clone.duplicate()
		display_message_panel.add_child(display_msg)
	
	#for player connected
	elif data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "Player_Connected":
		prev_data = data
		
		#remove old messages
		if display_message_panel.get_child_count() >= 5:
			var oldest = display_message_panel.get_child(0)
			oldest.queue_free()
		
		#add a new one
		if data.has("Player_GameID"):
			var display_msg = message_label.duplicate()
			display_msg.visible = true
			display_msg.add_theme_color_override("default_color", Color("#005400"))
			display_msg.text = data.get("Player_GameID") + " connected"
			display_message_panel.add_child(display_msg)
		
	#player disconnected
	elif data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "Player_Disconnect":
		prev_data = data
		
		#remove old messages
		if display_message_panel.get_child_count() >= 5:
			var oldest = display_message_panel.get_child(0)
			oldest.queue_free()
		
		#add a new one
		if data.has("Player_GameID"):
			var display_msg = message_label.duplicate()
			display_msg.visible = true
			display_msg.add_theme_color_override("default_color", Color("#ff0000"))

			display_msg.text = data.get("Player_GameID") + " disconnected"
			display_message_panel.add_child(display_msg)
			
		#get the player count and pass it to all clients
		var count = await gameData.updatePlayerCount(-1)
		
		if count:
			SocketClient.send_data({
				"Socket_Name": "PlayerCount",
				"Count": count
			})
