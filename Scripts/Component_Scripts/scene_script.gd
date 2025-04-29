extends Node

@export var scene_particle: CPUParticles2D
@export var main_player: CharacterBody2D

@onready var default_tree = preload("res://Sprite_Nodes/default_tree.tscn")
@export var ySort: Control

@export var max_scene_width_left = 2000
@export var max_scene_width_right = -1500.0
@export var max_scene_height_top = -1000.0
@export var max_scene_height_bottom = 1450.0

func _ready() -> void:
	if scene_particle:
		scene_particle.emitting = true
	
	#trees
	scatter_obj(default_tree, [Vector2(113, 4), Vector2(-184, 475), Vector2(-791, 475), Vector2(-586, -669), Vector2(1526, -736), Vector2(1526, -36), Vector2(1813, 1284)])

func _process(_delta: float):
	wrap_around()
	
func wrap_around():
	#going left
	if main_player.position.x >= max_scene_width_left:
		main_player.position.x = max_scene_width_right
	
	#going right
	elif main_player.position.x <= max_scene_width_right:
		main_player.position.x = max_scene_width_left
	
	#going down
	if main_player.position.y >= max_scene_height_bottom:
		main_player.position.y = max_scene_height_top
	
	#going up
	elif main_player.position.y <= max_scene_height_top:
		main_player.position.y = max_scene_height_bottom
		
func scatter_obj(obj, obj_pos):
	for pos in obj_pos:
		var clone_obj = obj.instantiate()
		clone_obj.position = Vector2(pos)
		ySort.add_child(clone_obj)
