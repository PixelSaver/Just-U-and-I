extends Node
class_name JUICredits

@export var all_parents : Array[Node]
@export var scroll_cont : ScrollContainer
@export var bg_cont : Node
var tweenables : Array[Tweenable] 

func _ready() -> void:
	tweenables = all_t()
	tweenables.sort_custom(func(a:Tweenable, b:Tweenable):
		return a.og_gl_pos.y < b.og_gl_pos.y
	)
	#scroll_cont.connect("scroll_position_changed", update_tweens)
	
func all_t() -> Array[Tweenable]:
	var out :Array[Tweenable] = []
	for parent in all_parents:
		for child in parent.get_children():
			for thing in child.get_children():
				if thing is Tweenable:
					out.append(thing) 
					thing.get_parent().global_position = thing.get_final_pos()
	return out

func _process(delta: float) -> void:
	update_tweens(scroll_cont.scroll_vertical)

var tween_index = 0;
func update_tweens(new_scroll_pos: float):
	bg_cont.global_position.y = -new_scroll_pos*2
	
	while tween_index < tweenables.size():
		var curr = tweenables[tween_index]
		#print(curr.name)
		#print(curr.og_gl_pos.y+bg_cont.global_position.y)
		if curr.og_gl_pos.y+bg_cont.global_position.y - curr.get_parent().pivot_offset.y <= get_viewport().get_visible_rect().size.y - 600:
			#tween_in(curr)
			tween_out(curr)
			tween_index += 1
		else:
			break

func tween_in(tweenable:Tweenable):
	print("tweened")
	tweenable.get_parent().modulate = Color.BLACK
	#var t = create_tween().set_trans(Tween.TRANS_QUINT)
	#t.set_parallel(true).set_ease(Tween.EASE_OUT)
	#t.tween_property(tweenable.get_parent(), "position", tweenable.og_gl_pos, 0.6)
func tween_out(tweenable:Tweenable):
	var t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_parallel(true).set_ease(Tween.EASE_OUT)
	t.tween_property(tweenable.get_parent(), "position", tweenable.og_pos, 0.6)


func _on_scroll_container_end_reached() -> void:
	pass # Replace with function body.
