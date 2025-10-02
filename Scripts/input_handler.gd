extends Control
class_name InputHandler

signal hovered(node: Control)
signal unhovered(node: Control)
signal clicked(node: Control)
signal input_mode_changed(mode: InputMode)

enum InputMode { MOUSE, KEYBOARD }
var current_input_mode: InputMode = InputMode.MOUSE
var is_hovered: bool = false

func _ready() -> void:
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and (event as InputEventMouse).relative:
		current_input_mode = InputMode.MOUSE
		update_hover_by_mouse()
	elif event is InputEventKey and event.pressed:
		current_input_mode = InputMode.KEYBOARD
		update_focus_by_keyboard(event)
		if has_focus():
			emit_hover()
	if Input.is_action_just_pressed("click_left") and is_hovered:
		clicked.emit(self)

func apply_hover():
	if not is_hovered and not has_focus(): return
	grab_focus()

func update_hover_by_mouse():
	if current_input_mode != InputMode.MOUSE:
		return
	var mouse_over = Rect2(Vector2.ZERO, get_parent().get_rect().size).has_point(get_local_mouse_position())
	if mouse_over:
		#print("mouse over node: %s" % str(self.name))
		#print("is hov: %s, has focus: %s" % [is_hovered, has_focus()])
		#if Global.mouse_focus_owner and Global.mouse_focus_owner != self:
			#return # another node already owns mouse focus
		if is_hovered and not has_focus(): 
			hovered.emit()
		elif is_hovered: return
		#Global.mouse_focus_owner = self
		is_hovered = true
		hovered.emit()
	else:
		#if Global.mouse_focus_owner == self:
			#Global.mouse_focus_owner = null
		is_hovered = false
		unhovered.emit()

func update_focus_by_keyboard(event: InputEventKey):
	if current_input_mode != InputMode.KEYBOARD:
		return
	is_hovered = false
	if has_focus():
		hovered.emit()

func update_hover() -> void:
	var mouse_over = Rect2(Vector2.ZERO, get_rect().size).has_point(get_local_mouse_position())
	if mouse_over:
		if not is_hovered:
			emit_hover()
	else:
		if is_hovered:
			emit_unhover()

func emit_hover() -> void:
	is_hovered = true
	get_parent().grab_focus()
	hovered.emit(self)

func emit_unhover() -> void:
	is_hovered = false
	unhovered.emit(self)

func _on_focus_entered() -> void:
	if current_input_mode == InputMode.KEYBOARD:
		emit_hover()

func _on_focus_exited() -> void:
	emit_unhover()
