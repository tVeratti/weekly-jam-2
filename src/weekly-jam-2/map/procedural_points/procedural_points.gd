class_name ProceduralPoints
extends Node


const POINT_GROUP:String = "line_point"
const BOUNDARY_GROUP:String = "boundary"
const POINT_CONTAINER_GROUP:String = "line_points_container"
const CURVE_ANIMATION_GROUP:String = "curve_animations"

const POINT_DISTANCE_X_MIN:float = 300.0
const POINT_DISTANCE_X_MAX:float = 600.0

const POINT_DISTANCE_Y_MIN:float = -200.0
const POINT_DISTANCE_Y_MAX:float = 200.0


func generate_container() -> Node2D:
	var container: = Node2D.new()
	container.name = "LinePoints"
	return container


func generate_points(container:Node2D, num_points:int, procedural_seed:int = 0) -> void:
	container.add_to_group(POINT_CONTAINER_GROUP, true)
	
	if procedural_seed:
		seed(procedural_seed)
	
	generate_point_nodes(num_points, container)


func generate_point_nodes(num_points:int, container:Node2D) -> void:
	# Add initial (0,0) point
	_add_point(Node2D.new(), container)
	
	var previous_position:Vector2 = Vector2.ZERO
	for i in range(num_points):
		var node: = Node2D.new()
		var next_position: = Vector2(
			previous_position.x + randf_range(POINT_DISTANCE_X_MIN, POINT_DISTANCE_X_MAX),
			0)
		
		node.position = next_position
		previous_position = next_position
		
		_add_point(node, container)
	
	var end_boundary: = Boundary.new()
	_add_boundary(end_boundary, container)


func _get_next_y(estimated_velocity:float, previous_y:float) -> float:
	if previous_y > 0:
		return randf_range(-POINT_DISTANCE_Y_MAX, -POINT_DISTANCE_Y_MAX / 2.0)
	else:
		# Don't go UP because velocity is already at 0
		return randf_range(POINT_DISTANCE_Y_MAX / 2.0, POINT_DISTANCE_Y_MAX * 2.0)


func _add_point(node:Node2D, container:Node2D) -> void:
	container.add_child(node)
	node.name = "LinePoint"
	node.add_to_group(POINT_GROUP, true)
	
	if Engine.is_editor_hint():
		var scene_root: = get_tree().edited_scene_root
		node.owner = scene_root


func _add_boundary(node:Node2D, container:Node2D) -> void:
	container.add_child(node)
	node.name = "Boundary"
	node.add_to_group(BOUNDARY_GROUP, true)
	
	if Engine.is_editor_hint():
		var scene_root: = get_tree().edited_scene_root
		node.owner = scene_root


func generate_animations(container:Node2D) -> AnimationPlayer:
	var points: = container.get_children()
	
	var animation: = Animation.new()
	var animation_library: = AnimationLibrary.new()
	animation_library.add_animation("curve", animation)
	
	var curve_animation_player: = AnimationPlayer.new()
	curve_animation_player.name = "CurveAnimation"
	curve_animation_player.unique_name_in_owner = true
	curve_animation_player.add_animation_library("", animation_library)
	
	container.add_child(curve_animation_player)
	if Engine.is_editor_hint():
		var scene_root: = get_tree().edited_scene_root
		curve_animation_player.owner = scene_root
	
	var previous_position:Vector2 = Vector2.ZERO
	var estimated_velocity:float = 0
	for point in points:
		var track_path: = "%s:position" % point.name
		var track_index: = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, track_path)
		animation.track_insert_key(track_index, 0.0, point.position)
		
		var curve_position: = Vector2(
			point.position.x,
			point.position.y + _get_next_y(estimated_velocity, previous_position.y))
		
		#var label = Label.new()
		#label.text = str(previous_position.y)
		#point.add_child(label)
		#label.owner = scene_root
		
		if point.position.x == 0:
			# First point should always tilt away from 0
			curve_position.y = -100
		
		animation.track_insert_key(track_index, 1.0, curve_position)
		animation.length = 1.0
		
		estimated_velocity += previous_position.y - curve_position.y
		previous_position = curve_position
	
	return curve_animation_player
