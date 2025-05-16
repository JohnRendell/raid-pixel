extends Node

@export var player_list_btn: Button

@export var player_info_panel: Panel
@export var player_name: RichTextLabel
@export var player_description: RichTextLabel
@export var player_profile: TextureRect
@export var player_gameID: RichTextLabel

@onready var player_list_panel = $"."
@onready var player_list_container = $"Content Panel/Player's list container"
@onready var player_name_button = $"Content Panel/Player Name Button"
@onready var http_request = $"player_list_HTTPRequest"
@onready var animationPlayer = $"AnimationPlayer"
@onready var player_list_panel_close_button = $"Content Panel/Close Button"

var isOpen = false

func _ready() -> void:
	player_list_panel.visible = false
	player_info_panel.visible = false
	
	player_list_btn.focus_mode = Control.FOCUS_NONE
	player_list_btn.connect("pressed", load_player_list)
	player_list_panel_close_button.connect("pressed", close_panel)
	
func close_panel():
	isOpen = false
	animationPlayer.play_backwards("pop_modal")
	
func load_player_list():
	if not PlayerGlobalScript.current_modal_open and not PlayerGlobalScript.isModalOpen:
		player_list_panel.visible = true
		isOpen = true
		animationPlayer.play("pop_modal")
		PlayerGlobalScript.current_modal_open = true
		PlayerGlobalScript.isModalOpen = true
		
		var list = GetPlayerInfo.active_player_dic
		
		for child in player_list_container.get_children():
			if child.name not in list.keys():
				child.queue_free()
		
		for gameID in list:
			var player_username = list[gameID]["Player_username"]
			var player_IGN = list[gameID]["Player_IGN"]
			
			if not player_list_container.has_node(gameID):
				var player_btn = player_name_button.duplicate()
				player_btn.name = gameID
				player_btn.text = "%s (%s)" % [player_IGN, gameID]
			
				player_btn.visible = true
				
				player_btn.connect("mouse_entered", func(): get_player_data(player_username, gameID))
				player_btn.connect("mouse_exited", func(): player_info_panel.visible = false)
				player_list_container.add_child(player_btn)
				
			else:
				var player_btn = player_list_container.get_node(gameID)
				player_btn.text = "%s (%s)" % [player_IGN, gameID]
			
			if list[gameID]["isFetched"]:
				await get_tree().create_timer(0.5).timeout
				list[gameID]["isFetched"] = false
				
func get_player_data(username, playerGameID):	
	player_info_panel.visible = true
	
	var result = await GetPlayerInfo.get_player_info(username, playerGameID)
	
	if result.has("status") and result["status"] == "Success":
		player_name.text = result["player_IGN"]
		player_description.text = result["player_description"]
		player_gameID.text = playerGameID
		http_request.request(result["player_profile"])

func _on_player_list_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var image = Image.new()
		var err = image.load_png_from_buffer(body)
		
		if err == OK:
			var texture = ImageTexture.create_from_image(image)
			player_profile.texture = texture
		else:
			print("Failed to load image from buffer:", err)
	else:
		print("HTTP request failed with code:", response_code)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pop_modal":
		player_list_panel.visible = isOpen
		PlayerGlobalScript.current_modal_open = isOpen
		PlayerGlobalScript.isModalOpen = isOpen
