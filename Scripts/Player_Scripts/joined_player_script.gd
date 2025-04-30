extends CharacterBody2D

@onready var player_anim = $"Player Sprite/AnimationPlayer"
@onready var player_sprite = $"Player Sprite"
@onready var player_ign = $"Player ign"

var isLeft = false
var isRight = false
var isDown = false
var isUp = false
var playerIGN = ""

var prev_pos = Vector2.ZERO

func _ready() -> void:
	player_anim.play("front_idle_anim")
	
func _process(_delta: float) -> void:
	player_ign.text = playerIGN
	var checkMovement = $".".position - prev_pos
	var isMoving = checkMovement != Vector2.ZERO
	prev_pos = $".".position

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
