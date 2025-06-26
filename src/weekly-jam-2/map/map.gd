extends Node2D


const LOCAL_POINT_DISTANCE:float = 800.0


@onready var collision_polygon:CollisionPolygon2D = %CollisionPolygon2D
@onready var line_2d:Line2D = %Line2D
@onready var line_segment:Path2D = %LineSegment
@onready var curve_animation:AnimationPlayer = %CurveAnimation
@onready var input_component:InputComponent = %InputComponent
@onready var static_body_2d = $StaticBody2D


var curve_speed:float = 10.0
var baked_points:PackedVector2Array = []

var ball:RigidBody2D
var ball_position:Vector2
var line_position:Vector2
var thread: = Thread.new()


func _ready() -> void:
	ball = get_tree().get_first_node_in_group("ball")
	
	curve_animation.current_animation = "curve"
	curve_animation.pause()
	
	var baked_polygon: = LineSegment.get_baked_polygon(baked_points)
	collision_polygon.polygon = baked_polygon


func _process(delta):
	if not thread.is_alive():
		thread.start(_calculate_localized_points)


func _physics_process(delta):
	ball_position = ball.global_position
	line_position = line_segment.global_position
	
	var input_direction:Vector2 = input_component.direction
	var current_animation_position:float = curve_animation.current_animation_position
	var next_animation_position:float = current_animation_position + (-input_direction.y * delta * 3.0)
	next_animation_position = clamp(next_animation_position, 0.0, 1.0)
	curve_animation.seek(next_animation_position, true)
	
	static_body_2d.global_position.x += input_direction.x * delta * 100
	line_2d.points = baked_points
	
	var baked_polygon: = LineSegment.get_baked_polygon(baked_points)
	collision_polygon.polygon = baked_polygon


func _calculate_localized_points() -> void:
	var localized_curve: = Curve2D.new()
	localized_curve.bake_interval = 30.0
	
	for i in line_segment.curve.point_count:
		var point:Vector2 = line_segment.curve.get_point_position(i) - line_position
		
		if ball_position.distance_to(point) <= LOCAL_POINT_DISTANCE:
			var point_in = line_segment.curve.get_point_in(i)
			var point_out = line_segment.curve.get_point_out(i)
			localized_curve.add_point(point, point_in, point_out)
	
	
	baked_points = localized_curve.get_baked_points()
	call_deferred("_localized_points_ready")


func _localized_points_ready() -> void:
	thread.wait_to_finish()
