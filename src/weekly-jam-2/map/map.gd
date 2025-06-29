class_name Map
extends Node2D


signal end_boundary_crossed


const MAX_HANDLE_X:float = 50.0
const LOCAL_POINT_DISTANCE:float = 2000.0
const CURVE_ANIMATION_SPEED:float = 4.0

const DIRECTION_TEXTURE:Texture = preload("uid://cljp2t7r1q18x")


var line_generator: = ProceduralPoints.new()

var curve_speed:float = CURVE_ANIMATION_SPEED
var baked_points:PackedVector2Array = []

var ball:RigidBody2D

var thread: = Thread.new()

var start_time:float = Time.get_ticks_msec()
var end_time:float

var level:int = 1


@onready var input_component:InputComponent = %InputComponent

# Floor / Line Body
@onready var line_body:StaticBody2D = %LineBody
@onready var collision_polygon:CollisionPolygon2D = %CollisionPolygon2D
@onready var line_2d:Line2D = %Line2D

# Animated Line Points
@onready var curve_animation:AnimationPlayer

@onready var timer_label:Label = %Timer
@onready var ghost_dots_0 = %GhostDots0
@onready var ghost_dots_1 = %GhostDots1
@onready var spawn:Node2D = $Spawn
@onready var hud = %HUD


func _ready() -> void:
	generate_line()
	
	input_component.reset.connect(_on_reset)
	
	var end_boundary:Boundary = get_tree().get_first_node_in_group(ProceduralPoints.BOUNDARY_GROUP)
	end_boundary.crossed.connect(_on_end_crossed)


func _process(_delta):
	ball = get_tree().get_first_node_in_group("ball")
	if not is_instance_valid(ball):
		return
	
	ghost_dots_0.modulate.a = curve_animation.current_animation_position
	ghost_dots_1.modulate.a = 1.0 - curve_animation.current_animation_position
	
	if not thread.is_alive():
		thread.start(_calculate_localized_points_async.bind(
			ball.global_position,
			_get_line_positions()))


func _physics_process(delta):
	_set_timer_text()
	
	if not is_instance_valid(ball):
		return
	
	var input_direction:Vector2 = input_component.direction
	_seek_animation(curve_animation, -input_direction.y, delta)
	
	line_2d.points = baked_points
	
	var baked_polygon: = LineSegment.get_baked_polygon(baked_points)
	collision_polygon.polygon = baked_polygon


func generate_line() -> void:
	# Remove the previously generated points
	var previous = get_tree().get_first_node_in_group(ProceduralPoints.POINT_CONTAINER_GROUP)
	if previous:
		previous.free()
	
	var container = line_generator.generate_container()
	add_child(container)
	
	line_generator.generate_points(container, 30.0, level)
	
	curve_animation = line_generator.generate_animations(container)
	curve_animation.current_animation = "curve"
	curve_animation.pause()
	
	# Create ghost lines
	_draw_stars(0, ghost_dots_0)
	_draw_stars(1, ghost_dots_1)


## Update line_points node positions by seeking AnimationPlayer animation position.
func _seek_animation(player:AnimationPlayer, input_amount:float, delta:float) -> void:
	var current_animation_position:float = player.current_animation_position
	var next_animation_position:float = current_animation_position + (input_amount * delta * curve_speed)
	
	next_animation_position = clamp(next_animation_position, 0.0, 1.0)
	player.seek(next_animation_position, true)


## Create a curve using `line_positions`, set `baked_points` to be used in `_physics_process`
static func calculate_localized_points(ball_position:Vector2, line_positions:Array) -> PackedVector2Array:
	var localized_curve: = Curve2D.new()
	localized_curve.bake_interval = 50.0
	
	for point in line_positions:
		if ball_position.distance_to(point) <= LOCAL_POINT_DISTANCE:
			var point_in: = Vector2(-MAX_HANDLE_X, 0)
			var point_out: = Vector2(MAX_HANDLE_X, 0)
			localized_curve.add_point(point, point_in, point_out)
	
	return localized_curve.get_baked_points()


func _calculate_localized_points_async(ball_position:Vector2, line_positions:Array) -> void:
	baked_points = calculate_localized_points(ball_position, line_positions)
	call_deferred("_localized_points_ready")


func _localized_points_ready() -> void:
	thread.wait_to_finish()


func _draw_stars(index:int, parent_node:Node) -> void:
	for child in parent_node.get_children():
		child.queue_free()
	
	curve_animation.seek(index, true)
	
	var points = _get_line_positions()
	for point in points:
		var sprite: = Sprite2D.new()
		sprite.texture = DIRECTION_TEXTURE
		sprite.global_position = point
		sprite.flip_v = index == 0
		sprite.scale = Vector2(0.5, 0.5)
		parent_node.add_child(sprite)


func _get_line_positions() -> Array:
	var line_points: = get_tree().get_nodes_in_group(ProceduralPoints.POINT_GROUP)
	return line_points.map(func(node): return node.global_position)


func _on_reset() -> void:
	start_time = Time.get_ticks_msec()
	ball = get_tree().get_first_node_in_group("ball")
	
	PhysicsServer2D.body_set_state(
		ball.get_rid(),
		PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY,
		Vector2.ZERO)
	
	PhysicsServer2D.body_set_state(
		ball.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(spawn.global_position))


func _set_timer_text() -> void:
	var now: = Time.get_ticks_msec()
	var elapsed_time: = now - start_time
	
	var seconds: = int(elapsed_time / 1000.0) % 60
	var minutes: = int(elapsed_time / 1000.0 / 60) % 60
	
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _on_end_crossed() -> void:
	end_time = Time.get_ticks_msec()
	end_boundary_crossed.emit()
