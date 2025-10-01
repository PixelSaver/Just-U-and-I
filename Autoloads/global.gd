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

var root

#func go_main_menu():
	#var mm = load("res://Scenes/main_menu.tscn").instantiate()
	#get_parent().add_child(mm)
	#
	#var tmenu = create_tween()
	#tmenu.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	#for but in buttons:
		#tmenu.tween_property(but, "position", but.position + (buttons[0].position - but.position)*.7, hide_duration)
	#tmenu.tween_property(mm, "modulate", Color(Color.WHITE,1), hide_duration*1.5)
	#
	#all_t = mm.all_tweenables()
	#for tween in all_t:
		#tween.get_parent().global_position = tween.get_final_pos()
		#tmenu.tween_property(tween.get_parent(), "global_position", tween.og_gl_pos, hide_duration)
