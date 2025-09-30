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

func _ready() -> void:
	print("Programs found: ", programs.size())
	
	for prog in programs:
		var i = prog as Program
		pos.append(i.position)
		rect.append(i.size)
		spr_pos.append(i.program_sprite.position)
	
	print("Stored positions: ", pos.size())
		
	for i in range(programs.size()):
		var p = programs[i] as Program
		var flash = ColorRect.new()
		p.spin_speed = [-0.1, 0.1][randi() % 2]
		flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		flash.size = Vector2.ONE * (p.size.length() * ((i + 1) * 2))
		flash.position = Vector2(size.y / 4, -size.y / 3)
		flash.rotation = 45
		flash.show_behind_parent = true
		flash.name = "flash"
		p.add_child(flash)
		p.program_label.modulate = Color(0, 0, 0, 5555)
		p.position.x += 1000 + p.size.x 
		p.position.y += p.size.y / 2
		p.size = Vector2.ZERO

func _input(event: InputEvent) -> void:
	# Handle touch input
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
	
	#if Input.is_action_just_pressed("click_left") or Input.is_action_just_pressed("ui_select"):
		#last_ms_pos = get_local_mouse_position().x
		#last_scroll = scroll
	
	#if Input.is_action_pressed("click_left") or touch:
		#if touch:
			#scroll = last_scroll - (get_local_mouse_position().x - last_ms_pos) * 3
		#else:
			#scroll = last_scroll - (get_local_mouse_position().x - last_ms_pos)
	
	for i in range(programs.size()):
		var p = programs[i] as Program
		
		if i < int(time_since_start):
			p.show()

			var t := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
			
			t.tween_property(p, "position", pos[i], 0.3)
			t.tween_property(p, "size", rect[i], 0.3)
			
			# Shine / Flash anim
			var flash := p.get_node_or_null("flash")
			if flash:
				t.tween_property(flash, "size:x", 0, 0.5).set_trans(Tween.TRANS_BACK)
