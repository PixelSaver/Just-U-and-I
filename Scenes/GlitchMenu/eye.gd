extends CanvasLayer
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
var is_mouse : bool = true

func _ready() -> void:
	blood_anim.play("blank")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		is_mouse = false
	elif event is InputEventMouseMotion:
		is_mouse = true

func _process(delta: float) -> void:
	eye_target = get_viewport().get_mouse_position()
	_update_pupil(delta)
	if Input.is_action_just_pressed("a"):
		anim_blood()
	

func _update_pupil(delta: float):
	var eye_center = pupil.get_parent().global_position
	var local_target : Vector2
	if not is_mouse and get_viewport().gui_get_focus_owner():
		var cont = get_viewport().gui_get_focus_owner()
		var cont_pos = cont.global_position + cont.size/2
		local_target = (cont_pos - eye_center) * pupil_mult
	else:
		local_target = (eye_target - eye_center) * pupil_mult

	## Width
	var a = 350
	## Height
	var b = 100

	# Clamp inside ellipse
	var ratio = sqrt((local_target.x*local_target.x)/(a*a) + (local_target.y*local_target.y)/(b*b))
	if ratio > 1:
		local_target /= ratio

	var target = eye_center + local_target
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
