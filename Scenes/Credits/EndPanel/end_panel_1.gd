extends Panel

signal anim_finished
@export var parent : Control
@export var bg_black : Control
@export var main_text : RichTextLabel
@export var mt_bg1 : Control
@export var mt_bg2 : Control
@export var bt1 : Button
@export var bt2 : Button
var tweenables : Array[Tweenable] = []

func _ready() -> void:
	all_t()
	for tw in tweenables:
		var par = tw.get_parent() as Control
		par.global_position = tw.get_final_pos()
	#start_anim()

func all_t():
	for child in parent.get_children():
		for thing in child.get_children():
			if thing is Tweenable:
				tweenables.append(thing)
func _gui_input(event: InputEvent) -> void:
	print("gui input")
var dur = 0.3
var t = null
func start_anim():
	if t: return
	grab_focus()
	print("started anim in panel")
	bg_black.pivot_offset = bg_black.size / 2
	bg_black.scale = Vector2(0.2, 0.1)
	main_text.visible_characters = 0
	mt_bg1.modulate.a = 0
	mt_bg2.modulate.a = 0
	bt1.modulate.a = 0
	bt2.modulate.a = 0
	bt1.scale = Vector2.ONE * 0.3
	bt2.scale = Vector2.ONE * 0.3
	
	t = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	t.tween_property(bg_black, "scale:x", 1, dur)
	t.chain().tween_property(bg_black, "scale:y", 1, dur)
	
	t.set_trans(Tween.TRANS_QUINT)
	for tw in tweenables:
		var par = tw.get_parent() as Control
		t.tween_property(par, "global_position", tw.og_gl_pos, dur)
		if tw.has_method("custom_tween"):
			tw.custom_tween(t, dur)
			
	_break_tween(t)
	
	# Bgs
	mt_bg1.global_position = mt_bg1.get_node("Tweenable").get_final_pos()
	t.tween_property(mt_bg1, "global_position", mt_bg1.get_node("Tweenable").og_gl_pos, dur)
	t.tween_property(mt_bg1, "modulate:a", 1, dur)
	#_break_tween(t)
	mt_bg2.global_position = mt_bg2.get_node("Tweenable").get_final_pos()
	t.tween_property(mt_bg2, "global_position", mt_bg2.get_node("Tweenable").og_gl_pos, dur)
	t.tween_property(mt_bg2, "modulate:a", 1, dur)
	
	t.chain()
	t.tween_property(main_text, "visible_characters", main_text.get_total_character_count(), dur*4)
	
	_break_tween(t)
	
	t.tween_property(bt1, "modulate:a", 1, dur)
	t.tween_property(bt1, "scale", Vector2.ONE, dur)
	bt1.disabled = false
	_break_tween(t)
	t.tween_property(bt2, "modulate:a", 1, dur)
	t.tween_property(bt2, "scale", Vector2.ONE, dur)
	bt2.disabled = false
	
func _break_tween(_t:Tween):
	_t.set_parallel(false)
	_t.tween_callback(_noop)
	_t.set_parallel(true)
func _noop():
	pass
