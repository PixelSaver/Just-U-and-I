extends Control
class_name PersonaMenu

@export var selector : PersonaSelector
@export var bg : Control
@export var all_parents : Array[Control]
@export var coin : Coin
@export var butn_foc : PersonaButton
var all_t : Array[Tweenable] = []
func _ready() -> void:
	selector.modulate.a = 0
	
	for parent in all_parents:
		for child in parent.get_children():
			for thing in child.get_children():
				if thing is Tweenable:
					all_t.append(thing)
	
	start_anim()

var is_animating = false
var dur = 0.4
func start_anim():
	if is_animating: return
	
	is_animating = true
	var t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_parallel(true).set_ease(Tween.EASE_OUT)
	
	#t.tween_property(self, "modulate:a", 1, dur)
	
	for thing in all_t:
		var table = thing as Tweenable
		if table.has_method("custom_tween"):
			table.custom_tween(t, dur)
		table.get_parent().global_position = table.get_final_pos()
		t.tween_property(table.get_parent(), "global_position", table.og_gl_pos, dur)
	
	butn_foc.grab_focus()
	await t.finished
	is_animating = false

func end_anim():
	if is_animating: return
	is_animating = true;
	
	Global.go_os()
	Global.state = Global.States.OS_MENU
	
	is_animating = true
	var t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_parallel(true).set_ease(Tween.EASE_OUT)
	
	#t.tween_property(self, "modulate:a", 1, dur)
	
	for thing in all_t:
		var table = thing as Tweenable
		if table.has_method("custom_tween"):
			table.custom_tween(t, dur)
		t.tween_property(table.get_parent(), "global_position", table.get_final_pos(), dur)
	
	
	await t.finished
	queue_free()

var selector_dur : float = 0.6
var s : Tween
func update_selector(node:Control):
	if s: s.kill()
	s = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	s.set_ease(Tween.EASE_OUT)
	s.tween_property(selector, "modulate:a", 1, selector_dur)
	s.tween_property(selector, "global_position", node.global_position + node.pivot_offset, selector_dur)
	
	if (selector.global_position - node.global_position - node.pivot_offset).length() > 0.01:
		selector.circle.scale = Vector2.ONE * 0.6
		s.set_ease(Tween.EASE_OUT)
		s.tween_property(selector.circle, "scale", Vector2.ONE*2.5*node.scale, selector_dur)
	s.tween_property(selector, "bar_width", 50*node.scale.x, selector_dur)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		bg.position = get_local_mouse_position()/80
	if Input.is_action_just_pressed("esc"):
		end_anim()
