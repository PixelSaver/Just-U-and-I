extends Control
class_name OSMenu

@export var program_parent : Control
@onready var programs : Array = program_parent.get_children()
@export var tween_parents : Array[Node]
@onready var tweenables : Array
@export var bg_arr : Array[Control]
@export var title : Control

var scroll = 0.0
var last_scroll = 0.0
var last_ms_pos = 0.0
var touch = false

var rect = []
var pos = []
var spr_pos = []
var time_since_start = 0.0
var animated_programs = [] 
var is_animating_programs = false


func _ready() -> void:
	tweenables = all_t()

var is_start_animating = false
func start_anim(dur:float=1.2):
	if is_animating_programs or is_start_animating: return
	
	is_start_animating = true
	var t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_parallel(true).set_ease(Tween.EASE_OUT)
	
	#t.tween_property(self, "modulate:a", 1, dur)
	
	
	for thing in tweenables:
		var table = thing as Tweenable
		if table.has_method("custom_tween"):
			table.custom_tween(t, dur)
		table.get_parent().global_position = table.get_final_pos()
		t.tween_property(table.get_parent(), "global_position", table.og_gl_pos, dur)
	
	#load_programs()
	
	await t.finished
	is_start_animating = false

func end_anim():
	if is_animating_programs or is_start_animating: return
	var is_start_animating = true
	
	var hide_duration = 0.5
	# For SettingsMenu
	var t_os = create_tween()
	t_os.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_IN)
	var all_t = tweenables
	for thing in all_t:
		var tween = thing as Tweenable
		t_os.tween_property(tween.get_parent(), "global_position", tween.get_final_pos(), hide_duration + tween.speed/25)
	t_os.tween_property(self, "modulate", Color(Color.WHITE,0), hide_duration*1.2)
	
	await t_os.finished
	Global.state = Global.States.MAIN_MENU

func all_t():
	var out : Array[Tweenable] = []
	for parent in tween_parents:
		for child in parent.get_children():
			var n = child as Control
			if child.get_child_count() == 0: continue
			var tweenable_index = n.get_children().find_custom(
				func(child) -> bool:
					return child is Tweenable
			)
			if tweenable_index == -1: continue
			var tweenable = n.get_children()[tweenable_index]
			out.append(tweenable)
	return out

func load_programs():
	if is_animating_programs: 
		return
	is_animating_programs = true
	animated_programs.clear() 
	time_since_start = 0.0
	
	if pos.is_empty():
		for prog in programs:
			var i = prog as Program
			pos.append(i.position)
			rect.append(i.size)
			spr_pos.append(i.program_sprite.position)
	
	for i in range(programs.size()):
		var p = programs[i] as Program
		var f = p.get_node_or_null("flash")
		if f:
			f.queue_free()
		
		p.program_label.modulate.a = 1
		p.position = pos[i] + Vector2(1000 + rect[i].x, rect[i].y / 2)
		p.size = Vector2.ZERO
		p.hide()
		p.spin_speed = [-0.1,0.1][randi() % 2]
		
		p.flash(rect[i], i)
		p.connect("flash_finished", func():
			is_animating_programs = false
		)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch = event.pressed
		if event.pressed:
			last_ms_pos = get_local_mouse_position().x
			last_scroll = scroll
	if Global.state != Global.States.OS_MENU: return
	if Input.is_action_pressed("scroll_down"): 
		scroll += 185
	if Input.is_action_pressed("scroll_up"): 
		scroll -= 185
	#if Input.is_action_just_pressed("click_left"):
		#start_anim()
	if Input.is_action_just_pressed("esc"):
		end_anim()
	
func _physics_process(delta: float) -> void:
	if time_since_start < programs.size():
		time_since_start += delta * 25
	
	program_parent.position.x += ((38 - scroll) - program_parent.position.x) * 0.2
	title.position.x = program_parent.position.x * 0.6
	# parallax!
	for i in range(bg_arr.size()):
		var layer_index := bg_arr.size() - i  
		bg_arr[i].position.x = program_parent.position.x * \
				pow(0.6, layer_index+1)
	
	if programs.size() > 0:
		var last_program = programs.back() as Program
		scroll += (clamp(scroll, 0, last_program.position.x + last_program.size.x - 450) - scroll) * 0.3
	
	if pos.is_empty(): 
		return
	
	for i in range(programs.size()):
		if i >= int(time_since_start) or i in animated_programs:
			continue
			
		var p = programs[i] as Program
		p.show() 
		
		var t := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
		t.tween_property(p, "position", pos[i], 0.3)
		t.tween_property(p, "size", rect[i], 0.3)
		
		#var flash := p.get_node_or_null("flash")
		#if flash:
			#var flash_tween = t.tween_property(flash, "size:x", 0, 0.5).set_trans(Tween.TRANS_BACK)
			#flash_tween.finished.connect(func(): 
				#if flash and is_instance_valid(flash):
					#flash.queue_free()
					#if i == programs.size() - 1:
						#is_animating_programs = false
			#)
		
		animated_programs.append(i)
