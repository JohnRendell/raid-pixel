extends Node

@onready var spawner_animation = $Sprite/AnimationPlayer
@export var joined_Player: CharacterBody2D

func _ready() -> void:
	spawner_animation.play("spawner_spawn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spawner_spawn":
		PlayerGlobalScript.main_player_spawned = true
		spawner_animation.play("spawner_idle")
