extends Node

#info of the player
var player_in_game_name: String
var player_game_id: String

#activation of the sprite of main player
var main_player_spawned = false

#Position of the main player
var player_pos_X = 0
var player_pos_Y = 0

#for player diamond amount
var player_diamond: float

#for player's movement restrict when modal is open
var isModalOpen = false

#for multiple modal flagging
var current_modal_open = false

#for player logged out that will validate on other script
var isLoggedOut = true

#for player type that will validate on other script
var player_type: String

#for username
var player_username: String

#for profile
var player_profile: String

#for player account type and UUID
var player_account_type: String
var player_UUID: String
