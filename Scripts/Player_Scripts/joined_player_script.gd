extends CharacterBody2D

@onready var player_anim = $"Player Sprite/AnimationPlayer"
@onready var player_sprite = $"Player Sprite"
@onready var player_ign = $"Player ign"
@onready var player_health_bar = $"Health Bar"
@onready var player_health_label = $"Health Bar/label"
var player_max_health = 100

var isLeft = false
var isRight = false
var isDown = false
var isUp = false
var isAttacking = false
var playerIGN = ""

var prev_pos = Vector2.ZERO

var player_type = ""

var player_ally_asset = preload("res://Assets/UI_Components/Sprite_Health_Ally_player.png")
var player_enemy_asset = preload("res://Assets/UI_Components/Sprite_Health_Enemy_player.png")

func _ready() -> void:
	player_health_bar.value = 100
	player_health_bar.texture_progress = player_enemy_asset if player_type == "enemy" else player_ally_asset
	
	player_anim.play("front_idle_anim")

#TODO: fix this, not stopping when player stop attacking
func play_punch_animation():
	if isRight or isLeft:
		player_anim.play("side_punch_anim")
	elif isUp:
		player_anim.play("back_punch_anim")
	elif isDown:
		player_anim.play("front_punch_anim")
	
func _process(_delta: float) -> void:
	player_ign.text = playerIGN
	var checkMovement = $".".position - prev_pos
	var isMoving = checkMovement != Vector2.ZERO
	prev_pos = $".".position

	if not isAttacking:
		if isLeft or isRight:
			if isMoving:
				player_anim.play("side_walk_anim")
			else:
				player_anim.play("side_idle_anim")
			player_sprite.flip_h = true if isLeft else false
		
		elif isUp:
			if isMoving:
				player_anim.play("back_walk_anim")
			else:
				player_anim.play("back_idle_anim")
		
		elif isDown:
			if isMoving:
				player_anim.play("front_walk_anim")
			else:
				player_anim.play("front_idle_anim")
	else:
		play_punch_animation()

func player_health_bar_status(status: float):
	player_health_bar.value += status
	player_health_label.text = int(player_health_bar.value)
