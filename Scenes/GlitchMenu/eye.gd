extends Control
class_name Eye

@export_category("Eye Sprites")
@export var pupil : Sprite2D
@export var white : Sprite2D
@export var blood_anim : AnimatedSprite2D
@export_category("Tweaks")
@export var pupil_mult : Vector2 = Vector2(0.3, 0.1)
@export var white_mult : Vector2 = Vector2(0.3, 0.1)
var mouse_pos : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = get_global_mouse_position()
		_update_pupil()

func _update_pupil():
	var normalized_mouse_pos = mouse_pos / get_viewport_rect().size - Vector2.ONE * 0.5
	var target_offset = normalized_mouse_pos * pupil_mult * get_viewport_rect().size
	var target = get_viewport_rect().size/2. + target_offset
	pupil.global_position = target
	
	target_offset = normalized_mouse_pos * white_mult * get_viewport_rect().size
	target = get_viewport_rect().size/2. + target_offset
	white.global_position = target
