extends Button
class_name PersonaButton

signal flash_finished
@export var is_title_bar := false
@export var button_sprite : Sprite2D 
@export var bg : Control
@export var button_label : RichTextLabel
@export var button_desc_label : RichTextLabel
@export var button_title : String = ""
@export var button_description : String = "I wonder why lorem ipsum is so dolores umbridge"
@export var tip : Control
@export var tip2 : Control
@export var tip2label: RichTextLabel
@export var all_parents : Array[Node]
@export var persona_hov : AudioStreamPlayer
@onready var input_handler : InputHandler = $InputHandler
@onready var menu : PersonaMenu = get_tree().get_first_node_in_group("PersonaMenu")
@onready var self_center_pos = pivot_offset + global_position

var hover_tween : Tween
var has_tip := false
var bg_og_pos : Vector2

func _ready():
	self.pivot_offset = size*scale / 2
	bg.pivot_offset = bg.size / 2
	bg_og_pos = bg.position
	input_handler.connect("activated", manual_foc_entered)
	input_handler.connect("deactivated", manual_foc_exited)
	og_scale = scale
	
	tip.hide()
	
	if button_label and button_desc_label and len(button_title)>0 and len(button_description)>0 and not is_title_bar:
		button_label.text = button_title
		button_desc_label.text = button_description
		has_tip = true
		tip.show()
		tip.modulate.a = 0
	elif tip2label and len(button_title) > 0 and is_title_bar:
		tip2.show()
		tip2.modulate.a = 0
		tip2label.text = button_title
	



var og_scale : Vector2
var hov_dur : float = 0.3
func manual_foc_entered():
	if persona_hov:
		persona_hov.play()
	z_index = 1
	if hover_tween:
		hover_tween.kill()
		
	menu.update_selector(self)
		
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", og_scale * 1.1, hov_dur)
	
	hover_tween.tween_property(button_sprite, "modulate", Color.BLACK, hov_dur)
	bg.modulate = Color(Color.WHITE, 0)
	
	if has_tip:
		tip.modulate.a = 0
		hover_tween.tween_property(tip, "modulate:a", 1, hov_dur)
	if is_title_bar:
		tip2.modulate.a = 0
		hover_tween.tween_property(tip2, "modulate:a", 1, hov_dur)
	hover_tween.tween_property(bg, "modulate", Color.WHITE, hov_dur) 
	hover_tween.tween_property(bg, "scale",Vector2.ONE * 1.3, hov_dur).set_ease(Tween.EASE_IN_OUT)
	
	hover_tween.tween_property(button_sprite, "position:y", -30, hov_dur/3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	hover_tween.set_parallel(false)
	hover_tween.tween_property(button_sprite, "position:y", 0, hov_dur/3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
func manual_foc_exited():
	if z_index == 0: return
	z_index = 0
	#if hover_tween:
		#hover_tween.kill()
	button_sprite.position.y = 0
	
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", og_scale, hov_dur)
	
	
	hover_tween.tween_property(button_sprite, "modulate", Color.WHITE, hov_dur)
	hover_tween.tween_property(bg, "modulate", Color.BLACK, hov_dur) 
	hover_tween.tween_property(bg, "scale",Vector2.ONE, hov_dur).set_ease(Tween.EASE_IN_OUT)
	if is_title_bar:
		bg.position.y = bg_og_pos.y + 70
		hover_tween.tween_property(bg, "position:y", bg_og_pos.y, hov_dur)
		hover_tween.tween_property(tip2, "modulate:a", 0, hov_dur)
	
	if has_tip:
		hover_tween.tween_property(tip, "modulate:a", 0, hov_dur)
		await hover_tween.finished
	
