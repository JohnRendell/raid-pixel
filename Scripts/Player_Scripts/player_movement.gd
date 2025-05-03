class_name PlayerMovement
extends CharacterBody2D

@export var speed = 400

var isLeft = false
var isRight = false
var isUp = false
var isDown = false

var isMoving = false

var isAttacking = false

var direction_value = 0

func get_input():
	if PlayerGlobalScript.isModalOpen == false:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		velocity = input_direction * speed
		
		isMoving = input_direction != Vector2.ZERO
		
		direction_value = input_direction
		if direction_value.x >= 1:
			isRight = true
			
			isLeft = false
			isDown = false
			isUp = false
		
		elif direction_value.x <= -1:
			isLeft = true
			
			isRight = false
			isDown = false
			isUp = false
			
		elif direction_value.y >= 1:
			isDown = true
			
			isUp = false
			isLeft = false
			isRight = false
			
		elif direction_value.y <= -1:
			isUp = true
			
			isDown = false
			isLeft = false
			isRight = false

func _physics_process(_delta):
	get_input()
	move_and_slide()
