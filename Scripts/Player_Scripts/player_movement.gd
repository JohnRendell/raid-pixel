class_name PlayerMovement
extends CharacterBody2D

@export var speed = 400

var isMoving = false
var isAttacking = false

var direction_value = Vector2.ZERO
var last_direction_value = Vector2.ZERO

func get_input():
	if not PlayerGlobalScript.isModalOpen:
		direction_value = Input.get_vector("left", "right", "up", "down")
		isMoving = direction_value != Vector2.ZERO
		velocity = direction_value * speed
		
		if isMoving:
			last_direction_value = direction_value

func _physics_process(_delta):
	get_input()
	move_and_slide()
