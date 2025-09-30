extends Control
class_name OSMenu

@export var program_parent : Control
@onready var programs : Array = program_parent.get_children()

var scroll = 0.0
var last_scroll = 0.0
var last_ms_pos = 0.0
var touch = false

var rect = []
var pos = []
var spr_pos = []
var time_since_start = 0.0
var animated_programs = [] 
var is_animating = false

func _ready() -> void:
	load_programs()

func load_programs():
	if is_animating: 
		return
	is_animating = true
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
		
		p.flash(rect[i], i, Vector2(size.y / 4, -size.y / 3 - 50))
		#var flash = ColorRect.new()
		#flash.name = "flash"
		#flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#flash.size = Vector2.ONE * (rect[i].length() * ((i + 1) * 2))
		#flash.position = Vector2(size.y / 4, -size.y / 3 - 500)
		#flash.rotation = 45
		#flash.show_behind_parent = true
		#p.add_child(flash)
		#p.spin_speed = [-0.1, 0.1][randi() % 2]

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch = event.pressed
		if event.pressed:
			last_ms_pos = get_local_mouse_position().x
			last_scroll = scroll
	
	if Input.is_action_pressed("scroll_down"): 
		scroll += 85
	if Input.is_action_pressed("scroll_up"): 
		scroll -= 85

func _physics_process(delta: float) -> void:
	if time_since_start < programs.size():
		time_since_start += delta * 25
	
	program_parent.position.x += ((38 - scroll) - program_parent.position.x) * 0.2
	
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
						#is_animating = false
			#)
		
		animated_programs.append(i)
