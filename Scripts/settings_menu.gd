extends Control
class_name SettingsMenu

@export var title: Panel
@export var button: ButtonSettings
@export var offset : float = 50
var buttons : Array[ButtonSettings] = []

func _ready() -> void:
	button.position = title.position + Vector2.ONE*200 + Vector2(0,15)
	buttons.append(button)
	button.og_pos = button.position
	for i in range(3):
		var inst = button.duplicate() as ButtonSettings
		add_child(inst)
		inst.position = button.position + Vector2.ONE*110*(i+1)
		inst.og_pos = inst.position
		buttons.append(inst)
	for _button in buttons:
		_button.connect("self_pressed", _on_pressed)
		_button.connect("hover", _on_hover)
		_button.connect("unhover", _on_unhover)

func _on_hover(but:ButtonSettings):
	var call = Callable(set_skewed_height).bind(but)
	var t = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	
	#t.tween_property(but.bg, "size:y", 100+offset, 0.5)
	t.tween_property(but, "size:y", 125+offset, 0.5)
	t.tween_property(but, "position", but.og_pos + Vector2(offset/2, 0), 0.5)
	#t.tween_property(but, "size", but.og_size + Vector2.ONE*offset*2, 0.5)
	
	for i in range(buttons.find(but)+1, buttons.size()):
		t.tween_property(buttons[i], "position", buttons[i].og_pos + Vector2.ONE*offset, 0.5)

func _on_unhover(but:ButtonSettings):
	var call = Callable(set_skewed_height).bind(but)
	var t = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	
	#t.tween_property(but.bg, "size:y", 100, 0.5)
	t.tween_property(but, "size:y", 125, 0.5)
	t.tween_property(but, "position", but.og_pos, 0.5)
	#t.tween_property(but, "size", but.og_size, 0.5)
	
	for i in range(buttons.find(but)+1, buttons.size()):
		t.tween_property(buttons[i], "position", buttons[i].og_pos, 0.5)

func _on_pressed(but:ButtonSettings):
	pass

func set_skewed_height(new_height: float, control:ButtonSettings) -> void:
	var skew = -1.0  # your shear factor
	var old_height = control.bg.size.y
	control.bg.size.y = new_height
	
	control.position.x = control.og_pos.x + (new_height-100)/2
