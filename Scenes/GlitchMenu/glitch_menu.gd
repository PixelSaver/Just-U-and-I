extends Control

signal anim_finished
@export var glitch_effect : ColorRect
@export var pixel_sort : ColorRect
@export var glitch_transition : ColorRect
var t : Tween

func _ready():
	glitch_effect_t(0)
	pixel_sort_t(0)
	glitch_trans_t(0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click_left"):
		anim()

func anim():
	if t: t.kill()
	
	t = create_tween().set_ease(Tween.EASE_IN)
	t.set_parallel(true).set_trans(Tween.TRANS_QUINT)
	
	t.tween_method(glitch_effect_t, 0., 1., 0.5)
	t.tween_method(pixel_sort_t, 0., 1., 0.5)
	t.tween_method(glitch_trans_t, 0., 1., 0.5)
	
	await t.finished
	anim_finished.emit()

func glitch_effect_t(val:float):
	var shader_mat = glitch_effect.material as ShaderMaterial
	shader_mat.set_shader_parameter("shake_rate", val)
func pixel_sort_t(val:float):
	var shader_mat = pixel_sort.material as ShaderMaterial
	shader_mat.set_shader_parameter("sort", val)
func glitch_trans_t(val:float):
	var shader_mat = glitch_transition.material as ShaderMaterial
	shader_mat.set_shader_parameter("fade", val)
