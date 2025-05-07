class_name PlayerProfile
extends Node

#for player profile contents
@onready var player_profile_view = $"Profile Modal/Profile View"

var prev_IGN = ""
var prev_gameID = ""
var prev_description = ""

#for profile
var description_profile = ""

func edit_profile_status(status: bool, in_game_name_input: LineEdit, description_input: TextEdit, cancel_edit_profile_button: Button, save_edit_profile_button: Button, edit_profile_button: Button, player_in_game_name_label: RichTextLabel, player_description_label: RichTextLabel):
	in_game_name_input.visible = status
	description_input.visible = status
	cancel_edit_profile_button.visible = status
	save_edit_profile_button.visible = status
	
	edit_profile_button.visible = !status
	
	player_in_game_name_label.visible = !status
	player_description_label.visible = !status

func render_player_profile_data(player_in_game_name_label: RichTextLabel, player_gameID_label: RichTextLabel, player_description_label: RichTextLabel):
	var inGameName = PlayerGlobalScript.player_in_game_name
	var gameID = PlayerGlobalScript.player_game_id
	
	if prev_IGN != inGameName:
		prev_IGN = inGameName
		player_in_game_name_label.text = prev_IGN
		
	if prev_gameID != gameID:
		prev_gameID = gameID
		player_gameID_label.text = prev_gameID
		
	if prev_description != description_profile:
		prev_description = description_profile
		player_description_label.text = prev_description
		
func get_player_data(http_request):
	var result = await ServerFetch.send_post_request(ServerFetch.backend_url + "playerInformation/playerData", { "username": PlayerGlobalScript.player_username })
	
	if result["status"] == "Success":
		PlayerGlobalScript.player_profile = result["profile"]
		PlayerGlobalScript.player_diamond = result["diamond"]
		PlayerGlobalScript.player_in_game_name = result["inGameName"]
		description_profile = result["description"]
	
		#load profile image
		var url = PlayerGlobalScript.player_profile
		http_request.request(url)
		
		return {
			"status": "Finished",
			"inGameName": result["inGameName"],
			"description": result["description"]
		}
	else:
		return {
			"status": "Failed"
		}
