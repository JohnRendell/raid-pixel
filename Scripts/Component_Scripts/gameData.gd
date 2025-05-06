class_name GameData
extends Node

var prev_data: Dictionary
var getPlayerCount = "Fetching..."
var time_scene = 0

#for getting time in scene
func get_scene_time(scene_name):
	var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "gameData/scene_cycle", { "scene_name": scene_name })
	
	if result and result["status"] == "Success":
		if result["scene_name"] == scene_name:
			return result["time"]
		else:
			return 0
	else:
		return 0

func player_logout(gameID: String):
	SocketClient.send_data({
		"Socket_Name": "Player_Logout",
		"GameID": gameID
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
