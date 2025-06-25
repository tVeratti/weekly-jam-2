extends Node3D

@onready var path_3d:Path3D = $Path3D
@onready var collision_polygon_3d:CollisionPolygon3D = $StaticBody3D2/CollisionPolygon3D


func _ready():
	_calculate_curve(1.0)


func _calculate_curve(percentage:float) -> void:
	var curve: = path_3d.curve
	var points: = curve.get_baked_points()
	
	# TODO: use percentage to lerp odd/even points up/down to create bumps
	collision_polygon_3d.polygon = _points_to_2d(points)


func _points_to_2d(points:PackedVector3Array) -> PackedVector2Array:
	return Array(points).map(func(point:Vector3):
		return Vector2(point.x, point.y))
