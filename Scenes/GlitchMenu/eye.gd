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
var mouse_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	blood_anim.play("blank")

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	_update_pupil(delta)
	if Input.is_action_just_pressed("a"):
		anim_blood()
	

func _update_pupil(delta:float):
	var viewport_center = get_viewport_rect().size / 2
	var local_mouse = (mouse_pos - viewport_center) * pupil_mult

	## Width
	var a = 350
	## Height
	var b = 100

	var ratio = sqrt((local_mouse.x*local_mouse.x)/(a*a) + (local_mouse.y*local_mouse.y)/(b*b))
	if ratio > 1:
		local_mouse /= ratio 

	var target = viewport_center + local_mouse
	var lerp_val = lerp(pupil.global_position, target, delta * pupil_speed)
	pupil.global_position = lerp_val
	white.global_position = lerp_val

func anim_blood():
	var t = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	t.tween_property(pupil, "modulate", Color.BLACK, 3.)
	t.tween_property(white, "modulate", Color.BLACK, 3.)
	t.tween_property(shading, "modulate", Color.BLACK, 3.)
	blood_anim.play("blood")
