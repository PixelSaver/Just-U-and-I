extends Control
class_name Program

@export var program_sprite : Sprite2D 
@export var program_label : RichTextLabel
@export var program_desc : String

var is_hovered : bool = false
var spin_speed : float = 0

func _process(delta: float) -> void:
	if is_hovered:
		pass

func _on_mouse_entered() -> void:
	#TODO Add a just hovered tween
	is_hovered = true


func _on_mouse_exited() -> void:
	#TODO CHeck if this isnecessary lol
	await get_tree().process_frame
	is_hovered = true
