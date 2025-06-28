class_name LineSegment
extends Node


const MAX_HANDLE_X:float = 50.0
const BAKED_POLYGON_MARGIN:float = 1000.0


## Given a baked set of points, close it with a large downward gap so that
## polygons can be created from this line without breaking geometry.
static func get_baked_polygon(points:PackedVector2Array) -> PackedVector2Array:
	if points.is_empty(): return []
	
	var highest_y:float = 0
	var highest_x:float = 0
	for p in points:
		if p.y > highest_y:
			highest_y = p.y
		
		if p.x > highest_x:
			highest_x = p.x
	
	highest_x += BAKED_POLYGON_MARGIN
	highest_y += BAKED_POLYGON_MARGIN
	
	var start_point: = points[0]
	var bottom_right: = Vector2(highest_x, highest_y)
	var bottom_left: = Vector2(start_point.x, highest_y)
	
	return points + PackedVector2Array([
		bottom_right,
		bottom_left,
		start_point
	])
	
