extends Node

@onready var panel = $"."
@export var modal_panel = Panel

var prev_status = true

func _ready():
	panel.visible = false

func _process(_delta: float) -> void:
	var status = modal_panel.isAnimDone
	
	if status != prev_status:
		prev_status = status
		panel.visible = status
