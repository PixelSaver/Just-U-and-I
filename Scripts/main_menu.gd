extends Control
class_name MainMenu

#TODO Make the actual button scene
const BUTTON_SCENE : PackedScene = preload("res://Scenes/button_menu.tscn")
@export var button_placement_container : Node
var buttons = []
const TITLES = ["PLAY", "OPTIONS", "EXTRAS", "QUIT"]
const SETTINGS_MENU = preload("res://Scenes/settings_menu.tscn")

func _ready() -> void:
	for child in button_placement_container.get_children():
		child.queue_free()
	for i in range(TITLES.size()):
		var inst = BUTTON_SCENE.instantiate() as CustomButton
		buttons.append(inst)
		button_placement_container.add_child(inst)
		inst.button_text.text = TITLES[i]
		inst.position.y = i*130
		inst.connect("self_pressed", _on_pressed)

func _on_pressed(name:String):
	match name:
		TITLES[0]: # Play
			handoff_to_setting()
		TITLES[1]: # Options
			pass
		TITLES[2]: # Extras
			pass
		TITLES[3]: # Quit
			get_tree().quit()



var duration : float = 0.8
@export var all_parents : Array[Node] = []
@export var scale_parent : Node

func all_tweenables() -> Array[Tweenable]:
	var out : Array[Tweenable] = []
	for parent in all_parents:
		for child in parent.get_children():
			var n = child as Control
			if child.get_child_count() == 0: continue
			var tweenable_index = n.get_children().find_custom(
				func(child) -> bool:
					return child is Tweenable
			)
			if tweenable_index == -1: continue
			var tweenable = n.get_children()[tweenable_index]
			out.append(tweenable)
	return out

func handoff_to_setting():
	var sett = SETTINGS_MENU.instantiate()
	sett.modulate = Color(Color.WHITE,0)
	get_parent().add_child(sett)
	#TODO do the transition
	var tmenu = create_tween()
	tmenu.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	for but in buttons:
		tmenu.tween_property(but, "position", but.position + (buttons[0].position - but.position)*.7, duration)
	tmenu.tween_property(self, "modulate", Color(Color.WHITE,0), duration*1.5)
	
	var all_t = all_tweenables()
	for tween in all_t:
		tmenu.tween_property(tween.get_parent(), "global_position", tween.get_final_pos(), duration)
	
	
	# For SettingsMenu
	var tsett = create_tween()
	tsett.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_IN)
	tsett.tween_property(sett, "modulate", Color(Color.WHITE,1), duration)
	all_t = sett.all_tweenables()
	for thing in all_t:
		var tween = thing as Tweenable
		tween.get_parent().global_position = tween.get_final_pos()
		tmenu.tween_property(tween.get_parent(), "global_position", tween.og_gl_pos, duration + tween.speed/20)
	
	return
	await get_tree().process_frame
	queue_free()
