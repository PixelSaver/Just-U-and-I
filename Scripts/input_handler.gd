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
	print("input mode: %s" % str(current_input_mode))

func update_active_state() -> void:
	var should_be_active: bool = false
	
	if current_input_mode == InputMode.MOUSE:
		should_be_active = is_hovered_mouse and parent.has_focus()
	else: # KEYBOARD
		should_be_active = parent.has_focus()
	
	if should_be_active != is_active:
		is_active = should_be_active
		if is_active:
			activated.emit()
		else:
			deactivated.emit()

func update_hover_by_mouse():
	if current_input_mode != InputMode.MOUSE:
		return
	
	var mouse_over = Rect2(Vector2.ZERO, parent.get_rect().size).has_point(get_local_mouse_position())
	is_hovered_mouse = mouse_over
	print("mouse over: %s" % mouse_over)
	
	if mouse_over and not parent.has_focus():
		parent.grab_focus()
	
	update_active_state()

func par_foc_entered() -> void:
	update_active_state()

func par_foc_exited() -> void:
	update_active_state()

func par_mouse_exited() -> void:
	is_hovered_mouse = false
	update_active_state()

func par_mouse_entered() -> void:
	current_input_mode = InputMode.MOUSE
	is_hovered_mouse = true
	if not parent.has_focus():
		parent.grab_focus()
	update_active_state()
