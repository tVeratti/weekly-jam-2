extends Node2D


const MAX_HANDLE_X:float = 50.0
const LOCAL_POINT_DISTANCE:float = 960.0
const CURVE_ANIMATION_SPEED:float = 4.0


@onready var input_component:InputComponent = %InputComponent

# Floor / Line Body
@onready var static_body_2d = $StaticBody2D
@onready var collision_polygon:CollisionPolygon2D = %CollisionPolygon2D
@onready var line_2d:Line2D = %Line2D

# Animated Line Points
@onready var curve_animation:AnimationPlayer = %CurveAnimation
@onready var line_points: = get_tree().get_nodes_in_group("line_point")


var curve_speed:float = CURVE_ANIMATION_SPEED
var baked_points:PackedVector2Array = []

var ball:RigidBody2D
var ball_position:Vector2
var line_positions:Array = []

var thread: = Thread.new()


func _ready() -> void:
	ball = get_tree().get_first_node_in_group("ball")
	
	curve_animation.current_animation = "curve"
	curve_animation.pause()


func _process(delta):
	line_positions = _get_line_positions()
	
	if not thread.is_alive():
		thread.start(_calculate_localized_points_async)


func _physics_process(delta):
	ball_position = ball.global_position
	
	var input_direction:Vector2 = input_component.direction
	_seek_animation(curve_animation, -input_direction.y, delta)
	
	line_2d.points = baked_points
	
	var baked_polygon: = LineSegment.get_baked_polygon(baked_points)
	collision_polygon.polygon = baked_polygon


## Update line_points node positions by seeking AnimationPlayer animation position.
func _seek_animation(player:AnimationPlayer, input_amount:float, delta:float) -> void:
	var current_animation_position:float = player.current_animation_position
	var next_animation_position:float = current_animation_position + (input_amount * delta * curve_speed)
	
	next_animation_position = clamp(next_animation_position, 0.0, 1.0)
	player.seek(next_animation_position, true)


## Create a curve using `line_positions`, set `baked_points` to be used in `_physics_process`
func _calculate_localized_points_async() -> void:
	var localized_curve: = Curve2D.new()
	localized_curve.bake_interval = 50.0
	
	for point in line_positions:
		if ball_position.distance_to(point) <= LOCAL_POINT_DISTANCE:
			var point_in: = Vector2(-MAX_HANDLE_X, 0)
			var point_out: = Vector2(MAX_HANDLE_X, 0)
			localized_curve.add_point(point, point_in, point_out)
	
	baked_points = localized_curve.get_baked_points()
	
	call_deferred("_localized_points_ready")


func _localized_points_ready() -> void:
	thread.wait_to_finish()


func _get_line_positions() -> Array:
	return line_points.map(func(node): return node.global_position)
