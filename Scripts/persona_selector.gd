extends Control
class_name PersonaSelector

@export var x : Control
@export var y : Control
@export var circle : Control

func _ready():
	x.pivot_offset = x.size / 2
	y.pivot_offset = y.size / 2
	circle.pivot_offset = circle.size / 2

func update_width(new_width:float):
	x.size.y = new_width
	y.size.x = new_width
	x.pivot_offset = x.size / 2
	y.pivot_offset = y.size / 2
	
