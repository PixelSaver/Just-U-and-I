extends CanvasLayer
class_name EndPanel

@export_category("1")
@export var panel1 : Panel
@export var text : RichTextLabel
@export_category("2")
@export var panel2 : Panel
@export_category("3")

func _ready():
	panel1.hide()
	panel1.hide()
	start_anim()

func start_anim():
	panel1.show()
	var dur1 = 5.7
	var t1 = create_tween().set_trans(Tween.TRANS_LINEAR).set_parallel(true)
	text.visible_characters = 0;
	t1.tween_property(text, "visible_characters", len(text.text), dur1)
