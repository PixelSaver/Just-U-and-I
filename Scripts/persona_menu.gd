extends Control
class_name PersonaMenu

@export var selector : PersonaSelector

func _ready() -> void:
	selector.modulate.a = 0

var selector_dur : float = 0.6
var s : Tween
func update_selector(node:Control):
	print("selected")
	if s: s.kill()
	s = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	s.set_ease(Tween.EASE_OUT)
	s.tween_property(selector, "modulate:a", 1, selector_dur)
	s.tween_property(selector, "global_position", node.global_position + node.pivot_offset, selector_dur)
	
	selector.circle.scale = Vector2.ONE * 0.5
	s.set_ease(Tween.EASE_OUT)
	s.tween_property(selector.circle, "scale", Vector2.ONE*2.5*node.scale, selector_dur)
	s.tween_property(selector, "bar_width", 60*node.scale.x, selector_dur)
