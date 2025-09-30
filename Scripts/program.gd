extends Control
class_name Program

@export var program_sprite : Sprite2D 
@export var program_label : RichTextLabel
@export var program_desc : String
@export var spr_offset : Vector2 = Vector2(3, 18)

var sprite_og_pos : Vector2
var is_hovered : bool = false
var spin_speed : float = 0
var idle_tween : Tween
var hover_tween : Tween

func _ready():
	sprite_og_pos = program_sprite.position
	_on_mouse_exited()

func _on_mouse_entered() -> void:
	is_hovered = true
	if idle_tween:
		idle_tween.kill()
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(program_sprite, "position", sprite_og_pos, 0.3)

func _on_mouse_exited() -> void:
	is_hovered = false
	if idle_tween:
		idle_tween.kill()
	
	idle_tween = create_tween().set_loops()
	var time = (position.length_squared() + Time.get_ticks_msec() * 0.001) * spin_speed
	var radius = 5.0
	var duration = 2.0
	
	for angle in range(0, 360, 30):
		var rad = deg_to_rad(angle + time)
		var wave = Vector2(cos(rad) * radius, sin(rad) * radius)
		var target = sprite_og_pos + spr_offset + wave
		idle_tween.tween_property(program_sprite, "position", target, duration / 12.0)
