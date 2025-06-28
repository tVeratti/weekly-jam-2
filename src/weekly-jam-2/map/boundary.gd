class_name Boundary
extends Node2D


signal crossed


func _process(_delta):
	var ball = get_tree().get_first_node_in_group("ball")
	if ball.global_position.x >= global_position.x:
		crossed.emit()
