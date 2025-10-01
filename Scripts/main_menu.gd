extends Control
class_name MainMenu

const BUTTON_SCENE : PackedScene = preload("res://Scenes/button_menu.tscn")
@export var button_placement_container : Node
var buttons = []
@export var ui_reject_audio : AudioStreamPlayer
@export var ui_enter : AudioStreamPlayer
@export var notif_man : NotificationManagerMenu
const TITLES = ["PLAY", "OPTIONS", "EXTRAS", "QUIT"]
const SETTINGS_MENU = preload("res://Scenes/settings_menu.tscn")
const OS_MENU = preload("res://Scenes/os_menu.tscn")

func _ready() -> void:
	Global.state = Global.States.MAIN_MENU
	start_main_menu()

func _on_pressed(val:ButtonMenu):
	var t : Tween
	var text = val.button_text.text
	match text:
		TITLES[0]: # Play
			Global.state = Global.States.OS_MENU
			end_main_menu()
			var os = OS_MENU.instantiate()
			get_parent().add_child(os)
			os.start_anim()
			os.modulate.a = 0
			var tw = create_tween().tween_property(os, "modulate:a", 1, 1.4).set_ease(Tween.EASE_OUT)
		TITLES[1]: # Options
			ui_enter.play()
			handoff_to_setting()
			t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			t.tween_property(val, "modulate", Color("#2b91ff"), 0.1)
			t.tween_property(val, "modulate", Color.WHITE, 0.3)
		TITLES[2]: # Extras
			ui_reject_audio.play()
			val.reject_anim()
			notif_man.show_notification("Content [color=#2b90fd]LOCKED[/color]")
		TITLES[3]: # Quit
			end_main_menu()
			t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			t.tween_property(val, "modulate", Color("#2b91ff"), 0.1)
			t.tween_property(val, "modulate", Color.WHITE, 0.3)
			await t.finished
			await get_tree().create_timer(0.4).timeout
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
	Global.state = Global.States.SETTINGS
	var sett = SETTINGS_MENU.instantiate()
	sett.modulate = Color(Color.WHITE,0)
	get_parent().add_child(sett)
	
	end_main_menu()
	
	duration = 0.5
	# For SettingsMenu
	var tsett = create_tween()
	tsett.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	var all_t = sett.all_tweenables()
	for thing in all_t:
		var tween = thing as Tweenable
		tween.get_parent().global_position = tween.get_final_pos()
		tsett.tween_property(tween.get_parent(), "global_position", tween.og_gl_pos, duration + tween.speed/25)
	tsett.tween_property(sett, "modulate", Color(Color.WHITE,1), duration*1.2)
	
	
	

func end_main_menu():
	var tmenu = create_tween()
	tmenu.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	for but in buttons:
		if !but: 
			tmenu.kill()
			return
		tmenu.tween_property(but, "position", but.position + (buttons[0].position - but.position)*.7, duration)
	tmenu.tween_property(self, "modulate", Color(Color.WHITE,0), duration*1.5)
	
	var all_t = all_tweenables()
	for tween in all_t:
		tmenu.tween_property(tween.get_parent(), "global_position", tween.get_final_pos(), duration)
	
	await tmenu.finished
	queue_free()

func start_main_menu():
	for child in button_placement_container.get_children():
		child.queue_free()
	for i in range(TITLES.size()):
		var inst = BUTTON_SCENE.instantiate() as ButtonMenu
		buttons.append(inst)
		button_placement_container.add_child(inst)
		inst.button_text.text = TITLES[i]
		inst.position.y = i*130
		inst.connect("self_pressed", _on_pressed)
		inst.init_position()
	
	await get_tree().process_frame
	
	var tmenu = create_tween()
	tmenu.set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	#TODO If you want then animate the buttons, just reverse this code
	#for but in buttons:
		#tmenu.tween_property(but, "position", but.position + (buttons[0].position - but.position)*.7, duration)
	#tmenu.tween_property(self, "modulate", Color(Color.WHITE,0), duration*1.5)
	modulate.a = 0
	tmenu.tween_property(self, "modulate:a", 1, duration*1.5)
	
	var all_t = all_tweenables()
	for tween in all_t:
		tween.get_parent().global_position = tween.get_final_pos()
		tmenu.tween_property(tween.get_parent(), "global_position", tween.og_gl_pos, duration)
