extends Node


## UI States
enum States {
	LOGO,
	TITLE_SCEEN,
	MAIN_MENU,
	SETTINGS,
	EXTRAS,
	OS_MENU,
	PROGRAM,
}

#TODO start from logo
#var state : States = States.LOGO
var state : States = States.MAIN_MENU

		

var root : Node

signal blue_coin_collected
var coins_collected = []
var blue_coins_collected = [] : 
	set(val):
		#TODO Add notif to blue coin, I don't think this works for .append()
		blue_coins_collected = val
		blue_coin_collected.emit(val.back())

func collect_blue_coin(node:Node):
	var bc_scene = load("res://Scenes/blue_coin.tscn").instantiate() as BlueCoin
	node.add_child(bc_scene)
	bc_scene.interacted_with()
	bc_scene.rotation = -bc_scene.get_global_transform().get_rotation()
	bc_scene.global_position = node.global_position

func go_main_menu():
	for child in root.get_children():
		if child is MainMenu:
			child.queue_free()
	var mm = load("res://Scenes/main_menu.tscn").instantiate() as MainMenu
	root.add_child(mm)
	mm.start_main_menu()
func go_os():
	for child in root.get_children():
		if child is OSMenu:
			child.queue_free()
	var os_menu = load("res://Scenes/os_menu.tscn").instantiate() as OSMenu
	root.add_child(os_menu)
	Global.state = Global.States.OS_MENU
func get_os() -> OSMenu:
	for child in root.get_children():
		if child is OSMenu:
			return child
	return null
func go_credits():
	for child in root.get_children():
		if child is JUICredits:
			child.queue_free()
	var cred_scene = load("res//Scenes/jui_credits.tscn").instantiate() as JUICredits
	root.add_child(cred_scene)
	Global.state = Global.States.EXTRAS
func restart():
	blue_coins_collected = []
	coins_collected = []
	go_main_menu()
	
