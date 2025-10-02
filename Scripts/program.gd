extends Control
class_name Program

signal flash_finished
@export var program_sprite : Sprite2D 
@export var program_label : RichTextLabel
@export var program_desc : String
@export var spr_offset : Vector2 = Vector2(3, 18)
@export var program_hov : AudioStreamPlayer
@onready var input_handler : InputHandler = $InputHandler

var sprite_og_pos : Vector2
var is_hovered : bool = false
var spin_speed : float = 0
var idle_tween : Tween
var hover_tween : Tween
enum InputMode { MOUSE, KEYBOARD }
var current_input_mode : InputMode = InputMode.MOUSE
var last_mouse_pos : Vector2 = Vector2.ZERO

func _ready():
	sprite_og_pos = program_sprite.position
	apply_idle_state()
	self.pivot_offset = size / 2
	input_handler.connect("activated", apply_hover_state)
	input_handler.connect("deactivated", apply_idle_state)
	

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
	t.tween_property(flash, "size:x", 0, dur + i / 8)
	t.finished.connect(func(): 
		if flash and is_instance_valid(flash):
			flash.queue_free()
			flash_finished.emit()
	)

func _gui_input(event: InputEvent) -> void:
	if Global.state != Global.States.OS_MENU:
		return
	input_handler.manual_gui_input(event)
	#if event is InputEventMouseMotion and (event as InputEventMouse).relative:
		#current_input_mode = InputMode.MOUSE
		#print("mouse, %s" % current_input_mode)
		##last_mouse_pos = event.position
		#update_hover_by_mouse()
	#if event is InputEventKey and event.pressed:
		#current_input_mode = InputMode.KEYBOARD
		#print("keyboard, %s" % current_input_mode)
		#update_focus_by_keyboard(event)
	if Input.is_action_just_pressed("click_left") and is_hovered:
		Global.collect_blue_coin(self)
	#print("input mode: %s" % current_input_mode)
#
#func update_hover_by_mouse():
	#if current_input_mode != InputMode.MOUSE:
		#return
	#var mouse_over = Rect2(Vector2.ZERO, get_rect().size).has_point(get_local_mouse_position())
	#if mouse_over:
		##print("mouse over node: %s" % str(self.name))
		##print("is hov: %s, has focus: %s" % [is_hovered, has_focus()])
		##if Global.mouse_focus_owner and Global.mouse_focus_owner != self:
			##return # another node already owns mouse focus
		##if is_hovered and not has_focus(): 
			##pass
			###apply_hover_state()
		#if is_hovered: return
		##Global.mouse_focus_owner = self
		#is_hovered = true
		##apply_hover_state()
	#else:
		##if Global.mouse_focus_owner == self:
			##Global.mouse_focus_owner = null
		#is_hovered = false
		#apply_idle_state()
#
#func update_focus_by_keyboard(event: InputEventKey):
	#if current_input_mode != InputMode.KEYBOARD:
		#return
	#is_hovered = false
	#if has_focus():
		#apply_hover_state()

func apply_hover_state():
	#if not is_hovered and not has_focus(): return
	if z_index == 1: return
	#grab_focus()
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

func apply_idle_state():
	if z_index == 0: return
	z_index = 0
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	if idle_tween:
		idle_tween.kill()
	idle_tween = create_tween().set_loops()
	var time = (Time.get_ticks_msec() * 0.001) * spin_speed
	var radius = 5.0
	var duration = 2.0
	for angle in range(0, 360, 30):
		var rad = deg_to_rad(angle + time)
		var wave = Vector2(cos(rad) * radius, sin(rad) * radius)
		var target = sprite_og_pos + spr_offset + wave
		idle_tween.tween_property(program_sprite, "position", target, duration / 12.0)

#func _on_mouse_entered() -> void:
	#if not has_focus(): 
		#grab_focus()
	#is_hovered = true
	#apply_hover_state()
#
#func _on_mouse_exited() -> void:
	#is_hovered = false
	#apply_idle_state()

func manual_focus_entered() -> void:
	#print(str(name) + " hovered")
	current_input_mode = InputMode.KEYBOARD
	#if not get_viewport_rect().encloses(get_global_rect()): print("input mode: %s" % current_input_mode)
	if not get_viewport_rect().encloses(get_global_rect()) and current_input_mode == InputMode.KEYBOARD: 
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

func manual_focus_exited() -> void:
	print(str(name) + " unhovered")
	#is_hovered = false
	apply_idle_state()

func check_out_of_bounds(control: Control) -> Vector2:
	var view_rect: Rect2 = get_viewport_rect()
	var rect: Rect2 = control.get_global_rect()   # use global rect, not local

	if rect.position.x < view_rect.position.x:
		print("Left out by: ", view_rect.position.x - rect.position.x)
		return Vector2(-1, view_rect.position.x - rect.position.x)

	if rect.end.x > view_rect.end.x:
		print("Right out by: ", rect.end.x - view_rect.end.x)
		return Vector2(1, rect.end.x - view_rect.end.x)
	return Vector2.ZERO
