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
	
func handoff_to_setting():
	get_parent().add_child(SETTINGS_MENU.instantiate())
	await get_tree().process_frame
	queue_free()
	#TODO do the transition
	return
	var tmenu = create_tween().set_ease(Tween.EASE_OUT)
	tmenu.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	
	var tsett = create_tween().set_ease(Tween.EASE_IN)
	tsett.set_trans(Tween.TRANS_QUINT).set_parallel(true)
