extends Control
class_name InputHandler

signal hovered(node: Control)
signal unhovered(node: Control)
signal clicked(node: Control)

enum InputMode { MOUSE, KEYBOARD }
@onready var parent = get_parent() as Control
var current_input_mode: InputMode = InputMode.MOUSE
var is_hovered: bool = false

func _ready() -> void:
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	parent.connect("_on_focus_entered", par_foc_entered)
	parent.connect("_on_focus_exited", par_foc_exited)
	parent.connect("_on_mouse_entered", par_mouse_entered)
	parent.connect("_on_mouse_exited", par_mouse_exited)

func par_mouse_exited() -> void:
	is_hovered = false

func par_mouse_entered() -> void:
	if not has_focus():
		grab_focus()
	is_hovered = true


func manual_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and (event as InputEventMouse).relative:
		current_input_mode = InputMode.MOUSE
		update_hover_by_mouse()
	elif event is InputEventKey and event.pressed:
		current_input_mode = InputMode.KEYBOARD
		update_focus_by_keyboard(event)

func apply_hover():
	if not is_hovered and not has_focus(): return
	hovered.emit()

func update_hover_by_mouse():
	if current_input_mode != InputMode.MOUSE:
		return
	var mouse_over = Rect2(Vector2.ZERO, parent.get_rect().size).has_point(get_local_mouse_position())
	if mouse_over:
		#print("mouse over node: %s" % str(self.name))
		#print("is hov: %s, has focus: %s" % [is_hovered, has_focus()])
		#if Global.mouse_focus_owner and Global.mouse_focus_owner != self:
			#return # another node already owns mouse focus
		if is_hovered: return
		#Global.mouse_focus_owner = self
		is_hovered = true
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

func par_foc_entered() -> void:
	is_hovered = false

func par_foc_exited() -> void:
	is_hovered = false
