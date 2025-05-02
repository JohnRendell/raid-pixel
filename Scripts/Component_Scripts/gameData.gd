class_name GameData
extends Node

var prev_data: Dictionary
var getPlayerCount = "Fetching..."

func player_logout():
	SocketClient.send_data({
		"Socket_Name": "Player_Logout",
		"GameID": PlayerGlobalScript.player_game_id
	})
		
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
