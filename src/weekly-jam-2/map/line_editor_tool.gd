@tool
extends Node2D


@export var map:Map
@export var line_2d:Line2D


@export_tool_button("Generate Line")
var button:Callable = generate_line


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func generate_line() -> void:
	var line_points = get_tree().get_nodes_in_group("line_point").map(func(node): return node.global_position)
	var baked_points = Map.calculate_localized_points(global_position, line_points)
	line_2d.points = baked_points


func _process(_delta):
	generate_line()
