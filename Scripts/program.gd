extends Control
class_name Program

signal flash_finished
@export var program_sprite : Sprite2D 
@export var program_label : RichTextLabel
@export var program_desc : String
@export var spr_offset : Vector2 = Vector2(3, 18)
@export var program_hov : AudioStreamPlayer

var sprite_og_pos : Vector2
var is_hovered : bool = false
var spin_speed : float = 0
var idle_tween : Tween
var hover_tween : Tween

func _ready():
	sprite_og_pos = program_sprite.position
	_on_mouse_exited()
	self.pivot_offset = size/2

func flash(rect:Vector2, i, dur=1):
	var flash = ColorRect.new()
	flash.name = "flash"
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.size.y = rect.y * 2.2
	flash.size.x = 800
	flash.pivot_offset = flash.size/2
	flash.position = -flash.size/3.3
	flash.scale.y = rect.y
	
	flash.rotation = 45
	flash.show_behind_parent = true
	add_child(flash)
	
	
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(flash, "size:x", 0, dur+ i/8)
	t.finished.connect(func(): 
		if flash and is_instance_valid(flash):
			flash.queue_free()
			flash_finished.emit()
	)

func _on_mouse_entered() -> void:
	program_hov.play()
	is_hovered = true
	z_index = 1
	if idle_tween:
		idle_tween.kill()
	if hover_tween:
		hover_tween.kill()
	
	flash(size, 0, 0.5)
	
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(program_sprite, "position", sprite_og_pos, 0.3)
	hover_tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.3)

func _on_mouse_exited() -> void:
	is_hovered = false
	if hover_tween:
		hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
		hover_tween.tween_property(self, "scale", Vector2.ONE * 1.0, 0.3)
		await hover_tween.finished
		hover_tween.kill()
	z_index = 0
	
	if idle_tween:
		idle_tween.kill()
	
	idle_tween = create_tween().set_loops()
	var time = (Time.get_ticks_msec() * 0.001) * spin_speed
	var radius = 5.0
	var duration = 2.0
	
	for angle in range(0, 360, 30):
		var rad = deg_to_rad(angle + time)
		var wave = Vector2(cos(rad) * radius, sin(rad) * radius)
		var target = sprite_og_pos + spr_offset + wave
		idle_tween.tween_property(program_sprite, "position", target, duration / 12.0)

func _input(event: InputEvent) -> void:
	if Global.state != Global.States.OS_MENU or not is_hovered: return
	if Input.is_action_just_pressed("click_left"):
		Global.collect_blue_coin(self)
