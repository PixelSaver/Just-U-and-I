extends Control
class_name PersonaSelector

@export var x : Control
@export var y : Control

func _ready():
	x.pivot_offset = x.size / 2
	y.pivot_offset = y.size / 2
