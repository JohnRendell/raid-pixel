extends Node

@export var map_scene_name: String

func _ready() -> void:
	PlayerGlobalScript.current_scene = map_scene_name
