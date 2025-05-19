extends Node

@onready var spawner_animation = $Sprite/AnimationPlayer

var joined_Player = preload("res://Sprite_Nodes/joined_player.tscn")
@export var ySort: Control
var prev_data: Dictionary

#store player here
var stored_players = {}

func _ready() -> void:
	spawner_animation.play("spawner_spawn")

func _process(_delta: float) -> void:
	var data = SocketClient.received_data()
	var connection_status = WebsocketsConnection.socket_connection_status
	
	if connection_status == "Connected":
		if data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "Player_Spawn" and data.get("Player_GameID") != PlayerGlobalScript.player_game_id:
			prev_data = data
			
			var player = joined_Player.instantiate()
			
			if data.get("Player_inGameName"):
				if not stored_players.has(data.get("Player_GameID")):
					GetPlayerInfo.active_player_dic[data.get("Player_GameID")] = {
						"Player_username": data.get("Player_username"),
						"Player_IGN": data.get("Player_inGameName"),
						"isFetched": false
					}
				
					stored_players[data.get("Player_GameID")] = {
						"Player": player,
						"Position": Vector2(2351.0, -161.0),
					}
					
					spawner_animation.play("spawner_spawn")
					player.playerIGN = data.get("Player_inGameName")
					player.player_type = data.get("player_type")
					ySort.add_child(player)
				else:
					var joined_player_data = stored_players[data.get("Player_GameID")]
					var joined_player = joined_player_data["Player"]
					joined_player.position = Vector2(data.get("Player_posX"), data.get("Player_posY"))
					joined_player.playerIGN = data.get("Player_inGameName")
					joined_player.isLeft = data.get("isLeft")
					joined_player.isRight = data.get("isRight")
					joined_player.isDown = data.get("isDown")
					joined_player.isUp = data.get("isUp")
					joined_player.player_type = data.get("player_type")
					joined_player.isAttacking = data.get("isAttacking")
				
		elif data.get("Socket_Name") and prev_data != data and (data.get("Socket_Name") == "Player_Disconnect" or data.get("Socket_Name") == "leave_lobby"):
			prev_data = data

			if data.has("Player_GameID") and stored_players.has(data.get("Player_GameID")):
				var joined_player_data = stored_players[data.get("Player_GameID")]
				var joined_player = joined_player_data["Player"]
				
				if joined_player_data:
					joined_player.queue_free()
					stored_players.erase(data.get("Player_GameID"))
					GetPlayerInfo.active_player_dic.erase(data.get("Player_GameID"))
					
		elif data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "ModifyProfile":
			prev_data = data
			
			if data.has("Player_GameID") and stored_players.has(data.get("Player_GameID")) and GetPlayerInfo.active_player_dic.has(data.get("Player_GameID")):
				
				var player_key_list = GetPlayerInfo.active_player_dic[data.get("Player_GameID")] 
				var joined_player_data = stored_players[data.get("Player_GameID")]
				var joined_player = joined_player_data["Player"]
				
				player_key_list.Player_IGN = data.get("Player_inGameName")
				joined_player.playerIGN = data.get("Player_inGameName")
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spawner_spawn":
		PlayerGlobalScript.main_player_spawned = true
		spawner_animation.play("spawner_idle")
