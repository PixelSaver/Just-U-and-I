extends Control
class_name MainMenu

#TODO Make the actual button scene
const BUTTON_SCENE : PackedScene = preload("res://Scenes/button.tscn")
@export var button_placement_container : Control
var buttons = []
const TITLES = ["PLAY", "OPTIONS", "EXTRAS", "QUIT"]

func _ready() -> void:
	for i in range(TITLES.size()):
		var inst = BUTTON_SCENE.instantiate() as CustomButton
		buttons.append(inst)
		button_placement_container.add_child(inst)
		inst.button_text.text = TITLES[i]
