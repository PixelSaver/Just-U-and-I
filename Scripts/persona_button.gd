extends Button
class_name PersonaButton

signal flash_finished
@export var is_title_bar := false
@export var button_sprite : Sprite2D 
@export var button_label : RichTextLabel
@export var button_desc_label : RichTextLabel
@export var button_title : String = ""
@export var button_description : String = "I wonder why lorem ipsum is so dolores umbridge"
@export var tip : Control
@export var spr_offset : Vector2 = Vector2(3, 18)
@export var persona_hov : AudioStreamPlayer
@onready var input_handler : InputHandler = $InputHandler
@onready var menu : PersonaMenu = get_tree().get_first_node_in_group("PersonaMenu")

var hover_tween : Tween
var has_tip := false

func _ready():
	self.pivot_offset = size*scale / 2
	input_handler.connect("activated", manual_foc_entered)
	input_handler.connect("deactivated", manual_foc_exited)
	og_scale = scale
	
	tip.hide()
	
	if button_label and button_desc_label and len(button_title)>0 and len(button_description)>0:
		button_label.text = button_title
		button_desc_label.text = button_description
		has_tip = true
		tip.show()
		tip.modulate.a = 0

var og_scale : Vector2
func manual_foc_entered():
	if persona_hov:
		persona_hov.play()
	z_index = 1
	if hover_tween:
		hover_tween.kill()
		
	menu.update_selector(self)
		
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", og_scale * 1.1, 0.3)
	if has_tip:
		tip.modulate.a = 0
		hover_tween.tween_property(tip, "modulate:a", 1, 0.3)
	
func manual_foc_exited():
	if z_index == 0: return
	z_index = 0
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", og_scale, 0.3)
	if has_tip:
		hover_tween.tween_property(tip, "modulate:a", 0, 0.3)
		await hover_tween.finished
	
