class_name GameData
extends Node

var prev_data: Dictionary
var getPlayerCount = "Fetching..."
	
func player_logout(validation_modal: Control, loading_modal: Control, gameID: String, username: String):
	if FileAccess.file_exists("user://login_data.json"):
		DirAccess.remove_absolute("user://login_data.json")
		
	PlayerGlobalScript.isLoggedOut = true
	validation_modal.visible = true
	
	SocketClient.send_data({
		"Socket_Name": "Player_Logout",
		"GameID": gameID,
		"Player_username": username
	})

	WebsocketsConnection.socket_connection_status = ""
	WebsocketsConnection.socket_data = {}
	
	# Disconnect WebSocket
	WebsocketsConnection.disconnect_to_socket()

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
		
func renderPlayerCount():
	var data = SocketClient.received_data()
	var connection_status = WebsocketsConnection.socket_connection_status

	if connection_status == "Connected":
		if data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "PlayerCount":
			prev_data = data
			
			if data.has("Count"):
				getPlayerCount = str(int(data.get("Count")))
			else:
				getPlayerCount = "Failed to get count"
	
	return getPlayerCount
	
func get_player_count():
	var result = await ServerFetch.get_request(ServerFetch.backend_url + "gameData/getPlayerCount")

	if result.has("status") and result["status"] == "Success":
		return int(result["count"])
	else:
		return 0
