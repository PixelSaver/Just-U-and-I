extends Node


## UI States
enum States {
	LOGO,
	TITLE_SCEEN,
	MAIN_MENU,
	SETTINGS,
	EXTRAS,
	OS_MENU,
}

#TODO start from logo
#var state : States = States.LOGO
var state : States = States.MAIN_MENU

var root : Node

func go_main_menu():
	for child in root.get_children():
		if child is MainMenu:
			child.queue_free()
	var mm = load("res://Scenes/main_menu.tscn").instantiate() as MainMenu
	root.add_child(mm)
	mm.start_main_menu()
