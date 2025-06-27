@tool
extends Node2D


@export var map:Map
@export var line_2d:Line2D

@export var line_seed:int = 1
@export var line_length:int = 100

@export_tool_button("Generate Line")
var button:Callable = generate_line

@export var auto_update:bool = false

var line_generator: = ProceduralPoints.new()


func _ready() -> void:
	add_child(line_generator)
	
	if not Engine.is_editor_hint():
		queue_free()


func generate_line() -> void:
	# Remove the previously generated points
	var previous = get_tree().get_first_node_in_group(ProceduralPoints.POINT_CONTAINER_GROUP)
	if previous:
		previous.free()
	
	var container = line_generator.generate_container()
	map.add_child(container)
	container.owner = map
	
	line_generator.generate_points(container, line_length, line_seed)
	line_generator.generate_animations(container)


func _process(_delta):
	if auto_update:
		var line_points = get_tree().get_nodes_in_group("line_point").map(func(node): return node.global_position)
		var baked_points = Map.calculate_localized_points(global_position, line_points)
		line_2d.points = baked_points
