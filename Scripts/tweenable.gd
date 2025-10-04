extends Node
class_name Tweenable

@export var dir : Vector2 = Vector2.ZERO
@export var speed : float = 0
var og_gl_pos : Vector2
var og_pos : Vector2
var par : Control

func _ready() -> void:
	par = get_parent() as Control
	og_gl_pos = par.global_position
	og_pos = par.position

func custom_tween(t:Tween, dur:float, is_inverse:bool=false):
	pass

func get_final_pos():
	return og_gl_pos + dir.normalized() * speed * 100

func get_delta():
	return dir.normalized() * speed * 100
