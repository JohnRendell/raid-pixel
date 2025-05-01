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
	
	if data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "Player_Spawn" and data.get("Player_inGameName") != PlayerGlobalScript.player_in_game_name:
		prev_data = data
		
		var player = joined_Player.instantiate()
		
		if not stored_players.has(data.get("Player_GameID")):
			stored_players[data.get("Player_GameID")] = {
				"Player": player,
				"Position": Vector2(2351.0, -161.0)
			}
			
			spawner_animation.play("spawner_spawn")
			player.playerIGN = data.get("Player_inGameName")
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
			
	elif data.get("Socket_Name") and prev_data != data and data.get("Socket_Name") == "Player_Disconnect":
		prev_data = data

		if data.has("Player_GameID") and stored_players.has(data.get("Player_GameID")):
			var joined_player_data = stored_players[data.get("Player_GameID")]
			var joined_player = joined_player_data["Player"]
			
			if joined_player_data:
				joined_player.queue_free()
				stored_players.erase(data.get("Player_GameID"))
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spawner_spawn":
		PlayerGlobalScript.main_player_spawned = true
		spawner_animation.play("spawner_idle")
