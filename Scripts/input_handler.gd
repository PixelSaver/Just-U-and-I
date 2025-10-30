extends Control
class_name InputHandler

signal activated()
signal deactivated
signal clicked

enum InputMode { MOUSE, KEYBOARD }

@onready var parent = get_parent() as Control
var current_input_mode: InputMode = InputMode.MOUSE
var is_hovered_mouse: bool = false
var is_active: bool = false
var input_handler_disabled : bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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

func update_hover_by_keyboard():
	if input_handler_disabled: return
	if current_input_mode != InputMode.KEYBOARD: return
	if parent.has_focus():
		activated.emit() 
	else:
		deactivated.emit()


func update_hover_by_mouse(override=false):
	if input_handler_disabled: return
	if current_input_mode != InputMode.MOUSE:
		return
	
	if not override:
		is_hovered_mouse = Rect2(Vector2.ZERO, parent.get_rect().size).has_point(get_local_mouse_position())
	
	if is_hovered_mouse:
		activated.emit()
		parent.grab_focus()
	else:
		deactivated.emit()

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
