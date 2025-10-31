extends Control
class_name Eye

@export_category("Eye Sprites")
@export var pupil : Sprite2D
@export var white : Sprite2D
@export var blood_anim : AnimatedSprite2D
@export var shading : Sprite2D
@export_category("Tweaks")
@export var pupil_mult : Vector2 = Vector2(0.3, 0.1)
#@export var white_mult : Vector2 = Vector2(0.3, 0.1)
@export_range(1., 10.) var pupil_speed : float = 1
var eye_target : Vector2 = Vector2.ZERO

func _ready() -> void:
	blood_anim.play("blank")

func _process(delta: float) -> void:
	eye_target = get_global_mouse_position()
	_update_pupil(delta)
	if Input.is_action_just_pressed("a"):
		anim_blood()
	

func _update_pupil(delta: float):
	var eye_center = pupil.get_parent().global_position
	var local_mouse = (eye_target - eye_center) * pupil_mult

	## Width
	var a = 350
	## Height
	var b = 100

	# Clamp inside ellipse
	var ratio = sqrt((local_mouse.x*local_mouse.x)/(a*a) + (local_mouse.y*local_mouse.y)/(b*b))
	if ratio > 1:
		local_mouse /= ratio

	var target = eye_center + local_mouse
	var lerp_val = pupil.global_position.slerp(target, delta * pupil_speed)

	pupil.global_position = lerp_val
	white.global_position = lerp_val

	var pupil_pos_normalized = (lerp_val - eye_center) * pupil_mult
	pupil.global_scale = Vector2(
		15 - pow(abs(pupil_pos_normalized.x / 100), 2),
		15 - pow(abs(pupil_pos_normalized.y / 17), 2)
	)
	white.global_scale = Vector2(
		22,
		22 - pow(abs(pupil_pos_normalized.y / 17), 2)
	)


func anim_blood():
	var t = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	t.tween_property(pupil, "modulate", Color.BLACK, 3.)
	t.tween_property(white, "modulate", Color.BLACK, 3.)
	t.tween_property(shading, "modulate", Color.BLACK, 3.)
	blood_anim.play("blood")
