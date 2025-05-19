extends Node

@onready var animation = $Sprite2D/AnimationPlayer
@export var player: CharacterBody2D

func _ready() -> void:
	print(player.name)

#TODO: fix this not working
func _on_player_door_area_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Main Player":
		print("enter")
		animation.play("door_anim")


func _on_player_door_area_body_exited(body: Node2D) -> void:
	if body.name == "Main Player":
		print("leave")
		animation.play_backwards("door_anim")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "door_anim":
		animation.pause()
