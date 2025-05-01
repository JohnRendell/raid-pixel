extends Node

@export var scene_particle: CPUParticles2D
@export var main_player: CharacterBody2D

@onready var default_tree = preload("res://Sprite_Nodes/default_tree.tscn")
@export var ySort: Control
@export var tileMap: TileMapLayer

var max_scene_width_left: float
var max_scene_width_right: float
var max_scene_height_top: float
var max_scene_height_bottom: float

var world_rect: Rect2

func _ready() -> void:
	if scene_particle:
		scene_particle.emitting = true
	
	#convert tile map layer into local world
	var tile_size = tileMap.tile_set.tile_size
	var used_rect = tileMap.get_used_rect()
	
	world_rect = Rect2(
		tileMap.map_to_local(used_rect.position),
		used_rect.size * tile_size
	)
	
	max_scene_width_left = world_rect.position.x + world_rect.size.x
	max_scene_width_right = world_rect.position.x
	max_scene_height_bottom = world_rect.position.y + world_rect.size.y
	max_scene_height_top = world_rect.position.y
	
	#trees
	scatter_obj(default_tree, [Vector2(2131, -121), Vector2(1587, 1334), Vector2(224, -1620), Vector2(4473, -1302), Vector2(4026, 158)])

func _process(_delta: float):
	wrap_around()
	adjust_player_camera_limit()
	
func adjust_player_camera_limit():
	var playerCamera = main_player.player_camera
	var map_limits = tileMap.get_used_rect()
	var map_cellsize = tileMap.tile_set.tile_size
	
	playerCamera.limit_left = map_limits.position.x * map_cellsize.x
	playerCamera.limit_right = map_limits.end.x * map_cellsize.x
	playerCamera.limit_top = map_limits.position.y * map_cellsize.y
	playerCamera.limit_bottom = map_limits.end.y * map_cellsize.y
	
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
