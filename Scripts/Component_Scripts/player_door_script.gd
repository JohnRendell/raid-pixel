extends Node

@onready var animation = $"Sprite/AnimationPlayer"
@export var loading_modal: Control
@export var ready_panel: Panel
@export var go_to_scene_button: Button

var prev_status = false

func _ready() -> void:
	ready_panel.visible = false
	go_to_scene_button.connect("pressed", head_to_game)
	
func head_to_game():
	if not PlayerGlobalScript.isModalOpen and not PlayerGlobalScript.current_modal_open:
		SocketClient.send_data({
			"Socket_Name": "leave_lobby",
			"Player_GameID": PlayerGlobalScript.player_game_id
		})
		loading_modal.load("res://Scenes/game_scene.tscn")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "door_anim":
		animation.pause()

func _on_player_door_area_area_entered(area: Area2D) -> void:
	if area.name == "Player Area" or area.name == "Main Player Area":
		if area.name == "Main Player Area":
			ready_panel.visible = true
			
		animation.play("door_anim")

func _on_player_door_area_area_exited(area: Area2D) -> void:
	if area.name == "Player Area" or area.name == "Main Player Area":
		if area.name == "Main Player Area":
			ready_panel.visible = false
		
		animation.play_backwards("door_anim")
