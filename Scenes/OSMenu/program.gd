extends Control
class_name Program

signal flash_finished
@export_category("Shatter Component")
@export var shatter_comp : ShatterComponent
@export_category("Program")
@export var program_sprite : Sprite2D 
@export var program_label : RichTextLabel
@export var program_desc : String
@export var spr_offset : Vector2 = Vector2(3, 18)
@export var program_hov : AudioStreamPlayer
@export var scene : PackedScene
@export_category("Misc")
@onready var input_handler : InputHandler = $InputHandler
@export var pressed_sound : AudioStreamPlayer
@export var glitch_effect : ColorRect
@export var shatter_fast : AudioStreamPlayer

var sprite_og_pos : Vector2
var og_mod : Color
var is_hovered : bool = false
var spin_speed : float = 0
var idle_tween : Tween
var hover_tween : Tween
enum InputMode { MOUSE, KEYBOARD }
var current_input_mode : InputMode = InputMode.MOUSE
var last_mouse_pos : Vector2 = Vector2.ZERO
var disabled := false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("d"):
		shatter_comp.shatter_all()
func _ready():
	sprite_og_pos = program_sprite.position
	apply_idle_state(true)
	self.pivot_offset = size / 2
	input_handler.connect("activated", apply_hover_state)
	input_handler.connect("deactivated", apply_idle_state)
	og_mod = modulate
	input_handler.input_handler_disabled = true
	
	
	var shader_mat = glitch_effect.material.duplicate() as ShaderMaterial
	glitch_effect.material = shader_mat
	if Global.glitched:
		randomize()
		shader_mat.set_shader_parameter("shake_rate", randf_range(0.2,0.5))
		glitch_effect.show()
	else:
		shader_mat.set_shader_parameter("shake_rate", 0.)
		glitch_effect.hide()

func _flash(rect:Vector2, i:int, dur:float=1):
	var flash = ColorRect.new()
	flash.name = "flash"
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.size.y = rect.y * 2.2
	flash.size.x = 800
	flash.pivot_offset = flash.size / 2
	flash.position = -flash.size / 3.3
	flash.scale.y = rect.y
	flash.rotation = 45
	flash.show_behind_parent = true
	add_child(flash)
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(flash, "size:x", 0., dur - float(i)/6.)
	t.finished.connect(func(): 
		if flash and is_instance_valid(flash):
			flash.queue_free()
			flash_finished.emit()
	)

func _gui_input(event: InputEvent) -> void:
	if Global.state != Global.States.OS_MENU or Global.get_os().is_animating_programs or Global.get_os().is_start_animating:
		return
	else:
		input_handler.input_handler_disabled = false
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("click_left") or Input.is_action_just_pressed("ui_select")) and has_focus():
		click()
	input_handler.manual_gui_input(event)

func click():
	if Global.glitched:
		shatter_comp.shatter_all()
		shatter_fast.play()
		disabled = true
		await shatter_comp.shatter_finished
		Global.get_os().programs.erase(self)
		queue_free()
		return
	modulate = og_mod * .7 + Color.DARK_ORCHID * .3
	scale = Vector2.ONE
	var t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.2)
	
	t.tween_property(self, "modulate", og_mod, 0.2)
	Global.collect_blue_coin(self)
		
	if pressed_sound:
		pressed_sound.play()
	
	if scene:
		var os : OSMenu
		for child in Global.root.get_children():
			if child is OSMenu:
				os = child
		if os.is_start_animating or os.is_animating_programs: return
		os.end_anim()
		var inst = scene.instantiate()
		Global.root.add_child(inst)
		inst.start_anim()
		Global.state = Global.States.PROGRAM

func apply_hover_state():
	if disabled: return
	
	if z_index == 1 or Global.state != Global.States.OS_MENU: return
	program_hov.play()
	z_index = 1
	if idle_tween:
		idle_tween.kill()
	if hover_tween:
		hover_tween.kill()
	_flash(size, 0, 0.5)
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(program_sprite, "position", sprite_og_pos, 0.3)
	hover_tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.3)
	if Global.glitched:
		hover_tween.tween_method(glitch_effect_t, 0., 1., 0.5)
	
	man_focus_entered()

func apply_idle_state(forced:=false):
	if disabled: return
	
	if z_index == 0: 
		if forced: pass
		else: return
	z_index = 0
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	if Global.glitched:
		hover_tween.tween_method(glitch_effect_t, 1., randf_range(0.01,0.3), 0.3)
	if idle_tween:
		idle_tween.kill()
	idle_tween = create_tween().set_loops()
	var rand = randf_range(0.,10.) if forced else 0.
	var time = (Time.get_ticks_msec() * 0.001) * spin_speed + rand
	var radius = 5.0
	var duration = 2.0
	for angle in range(0, 360, 30):
		var rad = deg_to_rad(angle + time)
		var wave = Vector2(cos(rad) * radius, sin(rad) * radius)
		var target = sprite_og_pos + spr_offset + wave
		idle_tween.tween_property(program_sprite, "position", target, duration / 12.0)

func man_focus_entered() -> void:
	if disabled: return
	
	if input_handler.current_input_mode == input_handler.InputMode.KEYBOARD: 
		var par : OSMenu = null
		for child in Global.root.get_children():
			if child is OSMenu:
				par = child
		if not par: return
		#BUG Only works ont he second time you pass over the program using keyboard... don't know why
		var out = check_out_of_bounds(self)
		var t = create_tween()
		t.tween_property(par, "scroll", par.scroll + (out.y+100) * out.x , 0.3)
	#is_hovered = false
	apply_hover_state()

func _process(_delta: float) -> void:
	glitch_effect.set_global_position(global_position)
	glitch_effect.set_size(size)
	glitch_effect.scale = scale

func check_out_of_bounds(control: Control) -> Vector2:
	var view_rect: Rect2 = get_viewport_rect()
	var rect: Rect2 = control.get_global_rect()   # use global rect, not local

	if rect.position.x < view_rect.position.x:
		return Vector2(-1, view_rect.position.x - rect.position.x)

	if rect.end.x > view_rect.end.x:
		return Vector2(1, rect.end.x - view_rect.end.x)
	return Vector2.ZERO

func glitch_effect_t(val:float):
	var shader_mat = glitch_effect.material as ShaderMaterial
	shader_mat.set_shader_parameter("shake_power", val/10.)
	shader_mat.set_shader_parameter("shake_rate", val + randf_range(-.1,.1))
