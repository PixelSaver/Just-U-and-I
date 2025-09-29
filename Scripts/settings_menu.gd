extends Control
class_name SettingsMenu

@export var title: Panel
@export var button: ButtonSettings
var buttons : Array[ButtonSettings] = []
var curr_selected : ButtonSettings 

func _ready() -> void:
	button.position = title.position + Vector2.ONE*200 + Vector2(0,15)
	button.connect("self_pressed", _on_pressed)
	buttons.append(button)
	button.og_pos = button.position
	for i in range(3):
		var inst = button.duplicate() as ButtonSettings
		add_child(inst)
		inst.position = button.position + Vector2.ONE*120*(i+1)
		inst.og_pos = inst.position
		buttons.append(inst)
	for button in buttons:
		button.connect("hover", _on_hover)
		button.connect("unhover", _on_unhover)

func _on_hover(but:ButtonSettings):
	var call = Callable(set_skewed_height).bind(but)
	var t = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_method(call, but.bg.size.y, 120, 0.5)
	for i in range(buttons.find(but)+1, buttons.size()):
		t.tween_property(buttons[i], "position", buttons[i].og_pos + Vector2(20,20), 0.5)

func _on_unhover(but:ButtonSettings):
	var call = Callable(set_skewed_height).bind(but)
	var t = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_method(call, but.bg.size.y, 100, 0.5)
	for i in range(buttons.find(but)+1, buttons.size()):
		t.tween_property(buttons[i], "position", buttons[i].og_pos, 0.5)

func _on_pressed(but:ButtonSettings):
	pass

func set_skewed_height(new_height: float, control:ButtonSettings) -> void:
	var skew = -1.0  # your shear factor
	var old_height = control.bg.size.y
	control.bg.size.y = new_height
	
	control.position.x = control.og_pos.x + (new_height-100)/2
