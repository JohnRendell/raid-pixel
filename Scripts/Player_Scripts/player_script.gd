extends PlayerMovement

@onready var player_anim = $"Player Sprite/AnimationPlayer"
@onready var player_sprite = $"Player Sprite"

func _ready() -> void:
	player_anim.play("front_idle_anim")
	
func _process(_delta: float) -> void:
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
