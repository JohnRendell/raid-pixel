extends Node

var active_player_dic: Dictionary

func get_player_info(player_username: String, dic_key):
	if not active_player_dic[dic_key]["isFetched"]:
		active_player_dic[dic_key]["isFetched"] = true
		
		var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "playerInformation/playerData", { "username": player_username })

		if result.has("status") and result["status"] == "Success":
			return {
				"status": result["status"],
				"player_IGN": result["inGameName"],
				"player_description": result["description"],
				"player_profile": result["profile"]
			}
		
	return 	{
		"status": "Fetched"
	}
