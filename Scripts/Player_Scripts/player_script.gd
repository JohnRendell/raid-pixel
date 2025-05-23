extends PlayerMovement

@onready var player_anim = $"Player Sprite/AnimationPlayer"
@onready var player_sprite = $"Player Sprite"
@onready var player_ign = $"Player ign"
@onready var player_camera = $"Camera2D"
@onready var player_health_bar = $"Health Bar"
@onready var player_health_label = $"Health Bar/label"
var player_max_health = 100

var prev_state = {}
var prev_ign = ""
var prev_coordinates = Vector2.ZERO

func _ready() -> void:
	player_health_bar.value = 100
	player_anim.play("front_idle_anim")
	
	await get_tree().process_frame
	PlayerGlobalScript.player_type = "Ally" if PlayerGlobalScript.current_scene.to_upper() == "LOBBY" else "Enemy"
		
func play_punch_animation():
	var dir_value = direction_value
	
	if isAttacking:
		if abs(dir_value.x) <= -1 or abs(dir_value.x) <= 1:
			play_anim("side_punch_anim")
		
		elif abs(dir_value.y) <= -1:
			play_anim("back_punch_anim")
		
		elif abs(dir_value.y) >= 1:
			play_anim("front_punch_anim")

	
func _process(_delta: float) -> void:
	if prev_ign != PlayerGlobalScript.player_in_game_name:
		prev_ign = PlayerGlobalScript.player_in_game_name
		player_ign.text = PlayerGlobalScript.player_in_game_name
		
	isAttacking = Input.is_action_pressed("punch") and PlayerGlobalScript.isModalOpen == false
	
	if isAttacking:
		play_punch_animation()
	else:
		move_player_animation()
	
	player_sprite.visible = PlayerGlobalScript.main_player_spawned
	
	if prev_coordinates != Vector2($".".position.x, $".".position.y):
		prev_coordinates = Vector2($".".position.x, $".".position.y)
		PlayerGlobalScript.player_pos_X = $".".position.x
		PlayerGlobalScript.player_pos_Y = $".".position.y
	send_player_data()
	
func move_player_animation():
	var dir_value = direction_value
	var x = dir_value.x
	var y = dir_value.y
	
	if isMoving:
		if abs(x) > abs(y):
			play_anim("side_walk_anim")
			player_sprite.flip_h = x <= -1
			
		elif y <= -1:
			play_anim("back_walk_anim")
		
		elif y >= 1:
			play_anim("front_walk_anim")
	else:
		var last_dir_x = last_direction_value.x
		var last_dir_y = last_direction_value.y
		
		if abs(last_dir_x) > abs(last_dir_y):
			play_anim("side_idle_anim")
			
		elif last_dir_y <= -1:
			play_anim("back_idle_anim")
		
		elif last_dir_y >= -1:
			play_anim("front_idle_anim")
	
func play_anim(anim_name):
	if player_anim.current_animation != anim_name:
		player_anim.play(anim_name)

func send_player_data():
	var current_state = {
			"Socket_Name": "Player_Spawn",
			"Player_username": PlayerGlobalScript.player_username,
			"Player_inGameName": PlayerGlobalScript.player_in_game_name,
			"Player_GameID": PlayerGlobalScript.player_game_id,
			"Player_posX": PlayerGlobalScript.player_pos_X,
			"Player_posY": PlayerGlobalScript.player_pos_Y,
			"isLeft": last_direction_value.x <= -1,
			"isRight": last_direction_value.x >= 1,
			"isDown": last_direction_value.y >= 1,
			"isUp": last_direction_value.y <= -1,
			"player_type": PlayerGlobalScript.player_type,
			"isAttacking": isAttacking
		}
	if isMoving or isAttacking or prev_state != current_state:
		SocketClient.send_data(current_state)
		prev_state = current_state.duplicate()

func player_health_bar_status(status: float):
	player_health_bar.value += status
	player_health_label.text = int(player_health_bar.value)
