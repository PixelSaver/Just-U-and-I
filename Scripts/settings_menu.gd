extends Control
class_name SettingsMenu

@export var title: Panel
@export var button: ButtonSettings
@export var offset : float = 50
var buttons : Array[ButtonSettings] = []
const TITLES = ["SOUND VOLUME", "AUDIO VOLUME", "FULLSCREEN", "HOW TO PLAY"]
var duration : float = 0.2

func _ready() -> void:
	button.position = title.position + Vector2.ONE*200 + Vector2(0,15)
	buttons.append(button)
	button.label.text = TITLES[0]
	button.og_pos = button.position
	for i in range(3):
		var inst = button.duplicate() as ButtonSettings
		add_child(inst)
		inst.position = button.position + Vector2.ONE*110*(i+1)
		inst.label.text = TITLES[i+1]
		inst.og_pos = inst.position
		buttons.append(inst)
	for _button in buttons:
		_button.connect("self_pressed", _on_pressed)
		_button.connect("hover", _on_hover)
		_button.connect("unhover", _on_unhover)
		_button.connect("is_ready", _on_button_ready)

func _on_hover(but:ButtonSettings):
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	
	t.tween_property(but, "size:y", 125+offset, duration)
	t.tween_property(but, "position", but.og_pos + Vector2(offset/2, 0), duration)
	t.tween_property(but.margin_label, "position:x", -offset/2, duration)
	t.tween_property(but.tip_panel, "global_position", but.tip_pos, duration)
	t.tween_property(but.tip_panel, "modulate", Color(Color.WHITE,1), duration)
	t.tween_property(but.bg, "modulate", Color.WHITE, duration)
	
	for i in range(buttons.find(but)+1, buttons.size()):
		t.tween_property(buttons[i], "position", buttons[i].og_pos + Vector2.ONE*offset, duration)

func _on_unhover(but:ButtonSettings):
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	
	t.tween_property(but, "size:y", 125, duration)
	t.tween_property(but, "position", but.og_pos, duration)
	t.tween_property(but.margin_label, "position:x", 0, duration)
	t.tween_property(but.tip_panel, "global_position", but.tip_pos + Vector2(offset, offset), duration)
	t.tween_property(but.tip_panel, "modulate", Color(Color.WHITE,.5), duration)
	t.tween_property(but.bg, "modulate", Color.BLACK, duration)
	
	for i in range(buttons.find(but)+1, buttons.size()):
		t.tween_property(buttons[i], "position", buttons[i].og_pos, duration)

func _on_button_ready(but:ButtonSettings):
	but.tip_panel.global_position = but.tip_pos + Vector2(offset, offset)

func _on_pressed(but:ButtonSettings):
	pass
