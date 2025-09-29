extends Button
class_name CustomButton

signal self_pressed(name:String)
@export var button_border: Panel 
@export var button_text: RichTextLabel 
@export var button_bg: ColorRect 

@export var tween_duration : float = 0.2
@export var pos_offset : Vector2 = Vector2(70,0)
var original_pos : Vector2
@export var trans : Tween.TransitionType = Tween.TRANS_QUINT
@export var tween_ease : Tween.EaseType = Tween.EASE_OUT

func _ready() -> void:
	await get_tree().process_frame
	original_pos = position

func _on_mouse_entered() -> void:
	
	var hovered = create_tween().set_trans(trans)
	hovered.set_parallel(true).set_ease(tween_ease)
	
	hovered.tween_property(button_border, "modulate", Color.BLACK, tween_duration)
	#hovered.tween_property(button_text, "modulate", Color.BLACK, tween_duration)
	hovered.tween_property(button_bg, "color", Color.WHITE, tween_duration)
	
	hovered.tween_property(self, "position", position + pos_offset, tween_duration)


func _on_mouse_exited() -> void:
	var unhovered = create_tween().set_trans(trans)
	unhovered.set_parallel(true).set_ease(tween_ease)
	
	unhovered.tween_property(button_border, "modulate", Color.WHITE, tween_duration)
	#unhovered.tween_property(button_text, "modulate", Color.WHITE, tween_duration)
	unhovered.tween_property(button_bg, "color", Color.BLACK, tween_duration)

	unhovered.tween_property(self, "position", original_pos, tween_duration)

func _on_button_down() -> void:
	self_pressed.emit(button_text.text)


func _on_button_up() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
