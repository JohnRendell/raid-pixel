extends PlayerMovement

@onready var player_anim = $"Player Sprite/AnimationPlayer"
@onready var player_sprite = $"Player Sprite"
@onready var player_ign = $"Player ign"

func _ready() -> void:
	print(PlayerGlobalScript.player_game_id)
	player_anim.play("front_idle_anim")
	
func _process(_delta: float) -> void:
	player_ign.text = PlayerGlobalScript.player_in_game_name
	var value = direction_value
	
	if isLeft or isRight:
		if value.x <= -1 or value.x >= 1:
			player_anim.play("side_walk_anim")
		else:
			player_anim.play("side_idle_anim")
		player_sprite.flip_h = true if isLeft else false
	
	elif isUp:
		if value.y <= -1:
			player_anim.play("back_walk_anim")
		else:
			player_anim.play("back_idle_anim")
	
	elif isDown:
		if value.y >= 1:
			player_anim.play("front_walk_anim")
		else:
			player_anim.play("front_idle_anim")
	
	player_sprite.visible = PlayerGlobalScript.main_player_spawned
	PlayerGlobalScript.player_pos_X = $".".position.x
	PlayerGlobalScript.player_pos_Y = $".".position.y
	
	send_player_data()
	
func send_player_data():
	if isMoving:
		SocketClient.send_data({
			"Socket_Name": "Player_Spawn",
			"Player_inGameName": PlayerGlobalScript.player_in_game_name,
			"Player_posX": PlayerGlobalScript.player_pos_X,
			"Player_posY": PlayerGlobalScript.player_pos_Y,
			"isLeft": isLeft,
			"isRight": isRight,
			"isDown": isDown,
			"isUp": isUp
		})
