class_name GameData
extends Node

var prev_data: Dictionary
var getPlayerCount = "Fetching..."

func updatePlayerCount(count: int):
	var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "gameData/modifyPlayerCount", {
		"playerCount": count
	})
	
	if result["status"] == "Succeed":
		return int(result["playerCount"])
	else:
		print(result["status"])
		return 0
		
func renderPlayerCount():
	var data = SocketClient.received_data()

	if data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "PlayerCount":
		prev_data = data
		
		if data.has("Count"):
			getPlayerCount = str(int(data.get("Count")))
		else:
			getPlayerCount = "Failed to get count"
	
	return getPlayerCount
