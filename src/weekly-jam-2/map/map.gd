extends Node2D


@onready var collision_polygon:CollisionPolygon2D = $StaticBody3D/CollisionPolygon2D
@onready var line_2d:Line2D = $StaticBody3D/Line2D
@onready var line_segment:Path2D = %LineSegment
@onready var curve_animation:AnimationPlayer = %CurveAnimation


func _process(_delta):
	if is_instance_valid(line_segment):
		var baked_points: = line_segment.curve.get_baked_points()
		line_2d.points = baked_points
		
		var baked_polygon: = LineSegment.get_baked_polygon(baked_points)
		collision_polygon.polygon = baked_polygon
