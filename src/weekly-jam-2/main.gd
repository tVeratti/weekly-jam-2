extends Node2D


@onready var map:Map = %Map
@onready var ball:Ball = %Ball

@onready var canvas_layer:CanvasLayer = %CanvasLayer
@onready var grid_container:GridContainer = %GridContainer


func _ready():
	map.hide()
	ball.hide()
	get_tree().paused = true
	
	for i in range(20):
		var button = Button.new()
		button.text = "Level %s" % i
		button.pressed.connect(_on_level_pressed.bind(i))
		grid_container.add_child(button)


func _on_level_pressed(level:int) -> void:
	get_tree().paused = false
	canvas_layer.hide()
	map.level = level
	map.show()
	map.generate_line()
	map._on_reset()
	ball.show()


func _on_end_boundary_crossed() -> void:
	canvas_layer.show()
	get_tree().paused = true
