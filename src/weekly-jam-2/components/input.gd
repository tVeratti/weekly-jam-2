class_name InputComponent
extends Node


const LEFT:String = "left"
const RIGHT:String = "right"
const UP:String = "up"
const DOWN:String = "down"
const RESET:String = "reset"


signal reset


var direction:Vector2 = Vector2.ZERO


func _process(_delta):
	direction = Vector2.ZERO
	
	if Input.is_action_pressed(LEFT):
		direction.x = -1
	elif Input.is_action_pressed(RIGHT):
		direction.x = 1
	
	if Input.is_action_pressed(UP):
		direction.y = -1
	elif Input.is_action_pressed(DOWN):
		direction.y = 1
	
	if Input.is_action_just_released(RESET):
		reset.emit()
