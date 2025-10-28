extends Control
class_name SettingsMenu

@export var title: Panel
@export var button: ButtonSettings
@export var offset : float = 50
@export var all_parents : Array[Node] 
@export var ui_exit : AudioStreamPlayer
var buttons : Array[ButtonSettings] = []
const TITLES = ["SOUND VOLUME", "AUDIO VOLUME", "FULLSCREEN", "HOW TO PLAY"]
const TIPS = ["BUTTONS ARE FOR CLICKING", "YOUR MOUSE IS FOR CLICKING", "THIS SCREEN IS FOR NOTHING", "CLICK Q OR ESC TO LEAVE!"]
const MAIN_MENU : PackedScene = preload("res://Scenes/MainMenu/main_menu.tscn")
var duration : float = 0.15

func _ready() -> void:
	
	button.position = title.position + Vector2.ONE*200 + Vector2(0,15)
	buttons.append(button)
	button.label.text = TITLES[0]
	button.tip_label.text = "TIP: " + TIPS[0]
	button.og_pos = button.position
	button.grab_focus()
	for i in range(3):
		var inst = button.duplicate() as ButtonSettings
		add_child(inst)
		inst.position = button.position + Vector2.ONE*110*(i+1)
		inst.label.text = TITLES[i+1]
		inst.tip_label.text = "TIP: " + TIPS[i+1]
		inst.og_pos = inst.position
		inst.name = "Settings%s" % str(i+1)
		buttons.append(inst)
	for _button in buttons:
		_button.connect("self_pressed", _on_pressed)
		_button.connect("hover", _on_hover)
		_button.connect("unhover", _on_unhover)
		_button.connect("is_ready", _on_button_ready)
	for i in range(buttons.size()):
		if i == 0:
			buttons[i].focus_neighbor_bottom = buttons[i+1].get_path()
		elif i == buttons.size()-1:
			buttons[i].focus_neighbor_top = buttons[i-1].get_path()
		else:
			buttons[i].focus_neighbor_top = buttons[i-1].get_path()
			buttons[i].focus_neighbor_bottom = buttons[i+1].get_path()

func _process(delta: float) -> void:
	if Global.state == Global.States.SETTINGS and Input.is_action_just_pressed("esc") and not is_animating:
		ui_exit.play()
		settings_hide()

var is_animating := false
var anim_dur = 0.5
func settings_show():
	if is_animating: return
	is_animating = true
	var tsett = create_tween()
	tsett.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	var all_t = all_tweenables()
	for thing in all_t:
		var tween = thing as Tweenable
		tween.get_parent().global_position = tween.get_final_pos()
		tsett.tween_property(tween.get_parent(), "global_position", tween.og_gl_pos, anim_dur + tween.speed/25)
	tsett.tween_property(self, "modulate", Color(Color.WHITE,1), anim_dur*1.2)
	await tsett.finished
	is_animating = false

func settings_hide():
	if is_animating: return
	is_animating = true
	Global.state = Global.States.MAIN_MENU
	
	var hide_duration = 0.5
	# For SettingsMenu
	var tsett = create_tween()
	tsett.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_IN)
	var all_t = all_tweenables()
	for thing in all_t:
		var tween = thing as Tweenable
		tsett.tween_property(tween.get_parent(), "global_position", tween.get_final_pos(), hide_duration + tween.speed/25)
	tsett.tween_property(self, "modulate", Color(Color.WHITE,0), hide_duration*1.2)
	
	
	# For Main Menu
	Global.go_main_menu()
	
	await tsett.finished
	queue_free()

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

func all_tweenables() -> Array[Tweenable]:
	var out : Array[Tweenable] = []
	for parent in all_parents:
		for child in parent.get_children():
			var n = child as Node
			if child.get_child_count() == 0: continue
			var tweenable_index = n.get_children().find_custom(
				func(child) -> bool:
					return child is Tweenable
			)
			if tweenable_index == -1: continue
			var tweenable = n.get_children()[tweenable_index]
			out.append(tweenable)
	return out

func _on_pressed(but:ButtonSettings):
	pass
