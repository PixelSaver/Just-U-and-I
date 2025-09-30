extends Button
class_name ButtonSettings

signal self_pressed(val:ButtonSettings)
signal hover(val:ButtonSettings)
signal unhover(val:ButtonSettings)
signal is_ready(val:ButtonSettings)
@export var bg : Panel
@export var label : RichTextLabel
@export var margin_label : MarginContainer
@export var tip_panel : Panel
@export var tip_label : RichTextLabel
var og_pos : Vector2 = Vector2.ZERO
var og_size : Vector2 
var tip_pos : Vector2

func _ready() -> void:
	og_size = size
	await get_tree().process_frame
	tip_pos = tip_panel.global_position
	tip_panel.modulate = Color(Color.WHITE, 0.5)
	is_ready.emit(self)

func _on_button_down() -> void:
	self_pressed.emit(self)


func _on_mouse_entered() -> void:
	hover.emit(self)


func _on_mouse_exited() -> void:
	unhover.emit(self)
