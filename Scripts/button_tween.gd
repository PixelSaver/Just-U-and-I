extends Button
class_name ButtonMenu

signal self_pressed(val:ButtonMenu)
@export var button_border: Panel 
@export var button_text: RichTextLabel 
@export var button_bg: ColorRect 

@export var tween_duration : float = 0.2
@export var pos_offset : Vector2 = Vector2(70,0)
var original_pos : Vector2
@export var trans : Tween.TransitionType = Tween.TRANS_QUINT
@export var tween_ease : Tween.EaseType = Tween.EASE_OUT
@export var hbox : Control

func _ready() -> void:
	await get_tree().get_first_node_in_group("MainMenu").ready
	original_pos = position

var hovered : Tween
func _on_mouse_entered() -> void:
	if unhovered != null: unhovered.kill()
	
	hovered = create_tween().set_trans(trans)
	hovered.set_parallel(true).set_ease(tween_ease)
	
	hovered.tween_property(button_border, "modulate", Color.BLACK, tween_duration)
	#hovered.tween_property(button_text, "modulate", Color.BLACK, tween_duration)
	hovered.tween_property(button_bg, "color", Color.WHITE, tween_duration)
	
	hovered.tween_property(self, "position", original_pos + pos_offset, tween_duration)
	#size = Vector2(400,110) + pos_offset
	#hbox.position = pos_offset
	#hovered.tween_property(self, "size", size + pos_offset, tween_duration)
	#hovered.tween_property(hbox, "position", pos_offset*2, tween_duration)

var unhovered : Tween
func _on_mouse_exited() -> void:
	
	unhovered = create_tween().set_trans(trans)
	unhovered.set_parallel(true).set_ease(tween_ease)
	
	unhovered.tween_property(button_border, "modulate", Color.WHITE, tween_duration)
	#unhovered.tween_property(button_text, "modulate", Color.WHITE, tween_duration)
	unhovered.tween_property(button_bg, "color", Color.BLACK, tween_duration)

	unhovered.tween_property(self, "position", original_pos, tween_duration)
	#size = Vector2(400,110)
	hbox.position = Vector2.ZERO
	#unhovered.tween_property(self, "size", Vector2(400,110), tween_duration)
	#unhovered.tween_property(hbox, "position", Vector2.ZERO, tween_duration)
	
	await unhovered.finished
	unhovered.kill()

func _on_button_down() -> void:
	self_pressed.emit(self)


func _on_button_up() -> void:
	pass # Replace with function body.

func reject_anim():
	pass
