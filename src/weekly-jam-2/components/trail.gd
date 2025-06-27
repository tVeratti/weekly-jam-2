class_name TrailLine
extends Line2D


const MAX_POINTS:int = 100


@export var target:Node2D = self
@export var shrink_inactive:bool = true
@export var is_active:bool = false : set = _set_is_active
@export var max_points:int = MAX_POINTS


var curve: = Curve2D.new()


func _ready():
	points = []


func _process(_delta):
	if is_active and is_instance_valid(target):
		width = 10.0
		curve.add_point(target.global_position - global_position)
		if curve.point_count >= max_points:
			curve.remove_point(0)
	
	else:
		if curve.point_count > 0:
			if shrink_inactive:
				curve.remove_point(0)
			
			var tween = get_tree().create_tween()
			tween.tween_property(self, "width", 0.0, width / 100.0)
	
	points = curve.get_baked_points()


func _set_is_active(value:bool) -> void:
	if value != is_active:
		is_active = value
