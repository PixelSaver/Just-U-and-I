extends Control
class_name PersonaSelector

@export var x : Control
@export var y : Control
@export var circle : Control
var bar_width : float = 0 :
	set(new_width):
		bar_width = new_width
		x.size.y = new_width
		y.size.x = new_width
		x.pivot_offset = x.size / 2
		y.pivot_offset = y.size / 2

func _ready():
	bar_width = x.size.y
	circle.pivot_offset = circle.size / 2
