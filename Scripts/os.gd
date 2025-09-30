extends Control
class_name OSMenu

@export var program_parent : Control
@onready var programs : Array = program_parent.get_children()

var scroll

var rect = []
var pos = []
var spr_pos = []
var fobber = false

func _ready() -> void:
	
	for prog in programs:
		var i = prog as Program
		pos.append(i.position)
		rect.append(i.size)
		spr_pos.append(i.program_sprite.position)
	for i in range(programs.size()):
		var p = programs[i] as Program
		var flash = ColorRect.new()
		#if fobber:
			#p.spin_speed = -0.1
		#else:
			#p.spin_speed = 0.1
		fobber = !fobber
		flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		flash.size = Vector2.ONE * (p.size.length() * (1 * ((i + 1) * 2)))
		flash.position = Vector2(size.y / 4,-size.y / 3)
		flash.rotation = 45
		flash.show_behind_parent = true
		flash.name = "flash"
		p.add_child(flash)
		p.program_label.modulate = Color(0,0,0,5555)
		p.position.x += 1000 + p.size.x 
		p.position.y += p.size.y / 2
		p.size = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed(""):
		scroll += 85
	if Input.is_action_pressed(""):
		scroll -= 85
