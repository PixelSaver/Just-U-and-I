extends Control
class_name GlitchMenu

signal first_anim_finished
@export var glitch_page : GlitchPage
@export var glitch_effect : ColorRect
@export var pixel_sort : ColorRect
@export var glitch_transition : ColorRect
@export var bg : ColorRect
var t : Tween

func _ready():
	Global.glitch_menu = self
	glitch_effect_t(0)
	pixel_sort_t(0)
	glitch_trans_t(0)
	glitch_page.hide()
	glitch_page.terminal_finished.connect(_on_term_fin)
	bg.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("glitch_debug") and OS.is_debug_build():
		first_anim()

func first_anim():
	if Global.state == Global.States.GLITCH: return
	Global.state = Global.States.GLITCH
	Global.glitched = true
	get_tree().paused = true
	if t: t.kill()
	
	t = create_tween()
	t.set_parallel(true).set_trans(Tween.TRANS_BOUNCE)
	
	#t.tween_method(glitch_effect_t, 0., 1., 0.6)
	#t.tween_method(pixel_sort_t, 0., 1., 1)
	
	t.tween_method(glitch_trans_t, 0., 1., 3.)
	
	await t.finished
	first_anim_finished.emit()

func _on_first_anim_finished() -> void:
	glitch_transition.hide()
	bg.show()
	
	glitch_page.modulate.a = 0.
	glitch_page.show()
	var tg = create_tween().set_ease(Tween.EASE_IN)
	tg.set_trans(Tween.TRANS_QUINT)
	tg.tween_property(glitch_page, "modulate:a", 1, 1.6)
	await tg.finished
	await get_tree().create_timer(1., true).timeout
	glitch_page.anim()

func _on_term_fin() -> void:
	get_tree().paused = false
	Global.kill_scenes_except_canvas()
	print("term fin")
	var end_t = create_tween().set_ease(Tween.EASE_OUT)
	end_t.set_parallel(true).set_trans(Tween.TRANS_QUINT)
	end_t.tween_property(self, "modulate:a", 0., 0.9)
	await end_t.finished
	self.hide()
	Global.go_main_menu()
	Global.setup_eye()
	queue_free()

func glitch_effect_t(val:float):
	var shader_mat = glitch_effect.material as ShaderMaterial
	shader_mat.set_shader_parameter("shake_rate", val)
func pixel_sort_t(val:float):
	var shader_mat = pixel_sort.material as ShaderMaterial
	shader_mat.set_shader_parameter("sort", val)
func glitch_trans_t(val:float):
	val = clamp(val, 0., 1.)
	var shader_mat = glitch_transition.material as ShaderMaterial
	shader_mat.set_shader_parameter("fade", val)
