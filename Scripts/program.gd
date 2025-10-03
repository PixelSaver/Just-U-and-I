extends Control
class_name Program

signal flash_finished
@export var program_sprite : Sprite2D 
@export var program_label : RichTextLabel
@export var program_desc : String
@export var spr_offset : Vector2 = Vector2(3, 18)
@export var program_hov : AudioStreamPlayer
@export var scene : PackedScene
@onready var input_handler : InputHandler = $InputHandler

var sprite_og_pos : Vector2
var og_mod : Color
var is_hovered : bool = false
var spin_speed : float = 0
var idle_tween : Tween
var hover_tween : Tween
enum InputMode { MOUSE, KEYBOARD }
var current_input_mode : InputMode = InputMode.MOUSE
var last_mouse_pos : Vector2 = Vector2.ZERO

func _ready():
	sprite_og_pos = program_sprite.position
	apply_idle_state(true)
	self.pivot_offset = size / 2
	input_handler.connect("activated", apply_hover_state)
	input_handler.connect("deactivated", apply_idle_state)
	og_mod = modulate
	input_handler.input_handler_disabled = true
	

func flash(rect:Vector2, i, dur=1):
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
	t.tween_property(flash, "size:x", 0, dur - i/6)
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
		modulate = og_mod * .7 + Color.DARK_ORCHID * .3
		scale = Vector2.ONE
		var t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
		t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.2)
		
		t.tween_property(self, "modulate", og_mod, 0.2)
		Global.collect_blue_coin(self)
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
	input_handler.manual_gui_input(event)
	

func apply_hover_state():
	if z_index == 1: return
	program_hov.play()
	z_index = 1
	if idle_tween:
		idle_tween.kill()
	if hover_tween:
		hover_tween.kill()
	flash(size, 0, 0.5)
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(program_sprite, "position", sprite_og_pos, 0.3)
	hover_tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.3)
	
	man_focus_entered()

func apply_idle_state(forced:=false):
	if z_index == 0: 
		if forced: pass
		else: return
	z_index = 0
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	if idle_tween:
		idle_tween.kill()
	idle_tween = create_tween().set_loops()
	var rand = randf_range(0,10) if forced else 0
	var time = (Time.get_ticks_msec() * 0.001) * spin_speed + rand
	var radius = 5.0
	var duration = 2.0
	for angle in range(0, 360, 30):
		var rad = deg_to_rad(angle + time)
		var wave = Vector2(cos(rad) * radius, sin(rad) * radius)
		var target = sprite_og_pos + spr_offset + wave
		idle_tween.tween_property(program_sprite, "position", target, duration / 12.0)

func man_focus_entered() -> void:
	if input_handler.current_input_mode == input_handler.InputMode.KEYBOARD: 
		var par : OSMenu = null
		for child in Global.root.get_children():
			if child is OSMenu:
				par = child
		if not par: return
		var out = check_out_of_bounds(self)
		var t = create_tween()
		t.tween_property(par, "scroll", par.scroll + (out.y+100) * out.x , 0.3)
	#is_hovered = false
	apply_hover_state()


func check_out_of_bounds(control: Control) -> Vector2:
	var view_rect: Rect2 = get_viewport_rect()
	var rect: Rect2 = control.get_global_rect()   # use global rect, not local

	if rect.position.x < view_rect.position.x:
		return Vector2(-1, view_rect.position.x - rect.position.x)

	if rect.end.x > view_rect.end.x:
		return Vector2(1, rect.end.x - view_rect.end.x)
	return Vector2.ZERO
