extends Button
class_name PersonaButton

signal flash_finished
@export var button_sprite : Sprite2D 
@export var button_label : RichTextLabel
@export var button_description : String
@export var spr_offset : Vector2 = Vector2(3, 18)
@export var persona_hov : AudioStreamPlayer
@onready var input_handler : InputHandler = $InputHandler
@onready var menu : PersonaMenu = get_tree().get_first_node_in_group("PersonaMenu")

var hover_tween : Tween

func _ready():
	self.pivot_offset = size / 2
	input_handler.connect("activated", manual_foc_entered)
	input_handler.connect("deactivated", manual_foc_exited)
	
func manual_foc_entered():
	if persona_hov:
		persona_hov.play()
	z_index = 1
	if hover_tween:
		hover_tween.kill()
		
	menu.update_selector(self)
		
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", Vector2.ONE * 1.1, 0.3)
	
func manual_foc_exited():
	if z_index == 0: return
	z_index = 0
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	
