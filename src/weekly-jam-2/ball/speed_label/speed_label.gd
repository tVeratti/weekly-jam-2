extends Node2D


const SPEED_PERCENTAGE_INTERVAL:float = 30.0

const MARGIN:float = 80.0
const BASE_FONT_SIZE:int = 24


var current_speed_interval:int

var tween

@onready var label:Label = $Label
@onready var parent_body:RigidBody2D = get_parent()


func _process(delta):
	var speed_length:float = parent_body.linear_velocity.length()
	var speed_percentage:float = max(0.01, speed_length / Ball.HIGH_SPEED_VELOCITY) * 100.0
	
	var speed_interval:float = clamp((snapped(speed_percentage / SPEED_PERCENTAGE_INTERVAL, 0.5)), 1.0, 10.0)
	label.text = str(int(snapped(speed_length, 10.0)))
	
	var speed_multiplier:float = max(1.0, speed_interval * 0.25)
	if speed_interval != current_speed_interval:
		if tween and tween.is_running():
			tween.kill()
		
		tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		if speed_interval > current_speed_interval:
			tween.tween_property(label, "label_settings:font_size", BASE_FONT_SIZE * (speed_multiplier * 1.2), 0.1)
		
		tween.tween_property(label, "label_settings:font_size", BASE_FONT_SIZE * speed_multiplier, 0.1)
		current_speed_interval = speed_interval
		
	global_position = lerp(
		global_position,
		parent_body.global_position - (Vector2(0, MARGIN) * speed_multiplier),
		delta * 10.0)
