extends PlayerMovement

@onready var player_anim = $"Player Sprite/AnimationPlayer"
@onready var player_sprite = $"Player Sprite"
@onready var player_ign = $"Player ign"
@onready var player_camera = $"Camera2D"
@onready var player_health_bar = $"Health Bar"
@onready var player_health_label = $"Health Bar/label"
var player_max_health = 100

var prev_state = {}

func _ready() -> void:
	player_health_bar.value = 100
	player_anim.play("front_idle_anim")

		
func play_punch_animation():
	if isRight or isLeft:
		player_anim.play("side_punch_anim")
	elif isUp:
		player_anim.play("back_punch_anim")
	elif isDown:
		player_anim.play("front_punch_anima")
	
func _process(_delta: float) -> void:
	player_ign.text = PlayerGlobalScript.player_in_game_name
	var value = direction_value
	isAttacking = Input.is_action_pressed("punch") and PlayerGlobalScript.isModalOpen == false
	
	if not isAttacking:
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
	else:
		play_punch_animation()
	
	player_sprite.visible = PlayerGlobalScript.main_player_spawned
	PlayerGlobalScript.player_pos_X = $".".position.x
	PlayerGlobalScript.player_pos_Y = $".".position.y
	
	send_player_data()
	
func send_player_data():
	var current_state = {
			"Socket_Name": "Player_Spawn",
			"Player_inGameName": PlayerGlobalScript.player_in_game_name,
			"Player_GameID": PlayerGlobalScript.player_game_id,
			"Player_posX": PlayerGlobalScript.player_pos_X,
			"Player_posY": PlayerGlobalScript.player_pos_Y,
			"isLeft": isLeft,
			"isRight": isRight,
			"isDown": isDown,
			"isUp": isUp,
			"player_type": PlayerGlobalScript.player_type,
			"isAttacking": isAttacking
		}
	if isMoving or isAttacking or prev_state != current_state:
		SocketClient.send_data(current_state)
		prev_state = current_state.duplicate()

func player_health_bar_status(status: float):
	player_health_bar.value += status
	player_health_label.text = int(player_health_bar.value)
