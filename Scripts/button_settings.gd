extends Button
class_name ButtonSettings

signal self_pressed(val:ButtonSettings)
signal hover(val:ButtonSettings)
signal unhover(val:ButtonSettings)
@export var bg : Panel
@export var label : RichTextLabel
var og_pos : Vector2 = Vector2.ZERO
var og_size : Vector2 

func _ready() -> void:
	og_size = size

func _on_button_down() -> void:
	self_pressed.emit(self)


func _on_mouse_entered() -> void:
	hover.emit(self)


func _on_mouse_exited() -> void:
	unhover.emit(self)
