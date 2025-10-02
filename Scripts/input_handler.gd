extends Control
class_name InputHandler

signal activated()
signal deactivated()
signal clicked()

enum InputMode { MOUSE, KEYBOARD }

@onready var parent = get_parent() as Control
var current_input_mode: InputMode = InputMode.MOUSE
var is_hovered_mouse: bool = false
var is_active: bool = false

func _ready() -> void:
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	parent.connect("focus_entered", par_foc_entered)
	parent.connect("focus_exited", par_foc_exited)
	parent.connect("mouse_entered", par_mouse_entered)
	parent.connect("mouse_exited", par_mouse_exited)

func manual_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		current_input_mode = InputMode.MOUSE
		update_hover_by_mouse()
	if event is InputEventKey and event.pressed:
		current_input_mode = InputMode.KEYBOARD
		update_hover_by_keyboard()
	#print("input mode: %s" % str(current_input_mode))

func update_hover_by_keyboard():
	if current_input_mode != InputMode.KEYBOARD: return
	if parent.has_focus():
		activated.emit() 
	else:
		deactivated.emit()

#func update_active_state() -> void:
	#var should_be_active: bool = false
	#
	#if current_input_mode == InputMode.MOUSE:
		#should_be_active = is_hovered_mouse
	#else: # KEYBOARD
		#should_be_active = parent.has_focus()
	#
	#if should_be_active != is_active:
		#is_active = should_be_active
		#if is_active:
			#activated.emit()
			#parent.grab_focus()
		#else:
			#deactivated.emit()

func update_hover_by_mouse(override=false):
	if current_input_mode != InputMode.MOUSE:
		return
	
	if not override:
		is_hovered_mouse = Rect2(Vector2.ZERO, parent.get_rect().size).has_point(get_local_mouse_position())
	
	if is_hovered_mouse:
		activated.emit()
		parent.grab_focus()
	else:
		deactivated.emit()
		#parent.grab_focus()
	
	#if mouse_over and not parent.has_focus():
		#parent.grab_focus()
	
	#update_active_state()

func par_foc_entered() -> void:
	activated.emit()

func par_foc_exited() -> void:
	deactivated.emit()

func par_mouse_exited() -> void:
	is_hovered_mouse = false
	update_hover_by_mouse(true)

func par_mouse_entered() -> void:
	current_input_mode = InputMode.MOUSE
	is_hovered_mouse = true
	update_hover_by_mouse(true)
