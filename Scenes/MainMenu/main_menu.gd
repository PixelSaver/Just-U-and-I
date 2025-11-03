extends Control
class_name MainMenu

const BUTTON_SCENE : PackedScene = preload("res://Scenes/button_menu.tscn")
@export var button_placement_container : Node
var buttons : Array[Control] = []
#TODO Consolidate all the audiostreamplayers into one node per scene or per global
@export var ui_reject_audio : AudioStreamPlayer
@export var ui_enter : AudioStreamPlayer
@export var ui_pressed : AudioStreamPlayer
@export var ui_enter_os : AudioStreamPlayer
@export var notif_man : NotificationManagerMenu
@export var ui_sound_cont : UISoundController
@export var coin : Coin
@export var title : RichTextLabel
@export var ui_exit : AudioStreamPlayer
@export var ui_glitched : AudioStreamPlayer
const TITLES = ["PLAY", "OPTIONS", "CLICK :)", "QUIT"]
const SETTINGS_MENU = preload("res://Scenes/Settings/settings_menu.tscn")
const OS_MENU = preload("res://Scenes/OSMenu/os_menu.tscn")

func _ready() -> void:
	Global.state = Global.States.MAIN_MENU
	coin.connect("collected", _on_coin_collected)
	
	await get_tree().process_frame
	#start_main_menu()
	

func _on_coin_collected(_coin:Coin):
	notif_man.show_notification("You just collected [color=#ffa506]1 coin!")
	notif_man.show_notification("You have collected [color=#ffa506]%s coins!" % str(Global.coins_collected.size()))

func _on_pressed(val:ButtonMenu):
	if is_animating: return
	var t : Tween
	var text = val.button_text.text
	match text:
		TITLES[0]: # Play
			
			Global.state = Global.States.OS_MENU
			if Global.glitched:
				end_main_menu_glitch()
				ui_glitched.play()
				await get_tree().create_timer(1.).timeout
				Global.go_os()
				ui_enter_os.play()
			else:
				end_main_menu()
				ui_enter_os.play()
				await get_tree().create_timer(0.5).timeout
				Global.go_os()
		TITLES[1]: # Options
			ui_enter.play()
			handoff_to_setting()
			t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			t.tween_property(val, "modulate", Color("#2b91ff"), 0.1)
			t.tween_property(val, "modulate", Color.WHITE, 0.3)
		TITLES[2]: # Extras
			if Global.glitched:
				ui_reject_audio.play()
				val.reject_anim()
				notif_man.show_notification("Content [color=#2b90fd]OUT OF ORDER[/color]")
			else:
				try_ending(val)
		TITLES[3]: # Quit
			end_main_menu()
			ui_exit.play()
			#t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			#t.tween_property(val, "modulate", Color("#2b91ff"), 0.1)
			#t.tween_property(val, "modulate", Color.WHITE, 0.3)
			#await t.finished
			await get_tree().create_timer(0.7).timeout
			get_tree().quit()

func try_ending(val:ButtonMenu):
	if Global.coins_collected.size() < 3:
		ui_reject_audio.play()
		val.reject_anim()
		notif_man.show_notification("Content [color=#2b90fd]LOCKED[/color]: [color=#ffa506]3 coins[/color] needed")
		notif_man.show_notification("You have collected [color=#ffa506]%s coins!" % str(Global.coins_collected.size()))
	else:
		Global.glitch_menu.first_anim()
		#Global.go_credits()
		#end_main_menu()
		

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
				func(_child) -> bool:
					return _child is Tweenable
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
	
	sett.settings_show()

func end_main_menu():
	if is_animating: return
	is_animating = true;
	ui_sound_cont.disabled = true
	
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

func end_main_menu_glitch():
	if is_animating: return
	is_animating = true;
	ui_sound_cont.disabled = true
	
	var tmenu = create_tween()
	tmenu.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	tmenu.set_ease(Tween.EASE_OUT)
	for but in buttons:
		if !but: 
			tmenu.kill()
			return
		tmenu.tween_property(but, "position", but.position + (buttons[0].position - but.position)*.7, duration)
	tmenu.tween_property(self, "modulate", Color(Color.WHITE,0), 2.4)
	tmenu.tween_method(Global.glitch_menu.pixel_sort_t, 0., 1., 2.4)
	
	var all_t = all_tweenables()
	for tween in all_t:
		tmenu.tween_property(tween.get_parent(), "global_position", tween.get_final_pos(), duration)
	
	await tmenu.finished
	Global.glitch_menu.pixel_sort_t(0)
	queue_free()

var is_animating = false;
func start_main_menu():
	if is_animating: return
	is_animating = true;
	for child in Global.root.get_children():
		if child is MainMenu and child != self:
			child.queue_free()
	
	# Easter Egg!!!!!
	if Global.coins_collected.size() >= 3:
		title.clear()
		title.append_text("[font_size=65]JUST U & I")
	
	for child in button_placement_container.get_children():
		child.queue_free()
	for i in range(TITLES.size()):
		var inst = BUTTON_SCENE.instantiate() as ButtonMenu
		buttons.append(inst)
		button_placement_container.add_child(inst)
		inst.button_text.text = TITLES[i]
		inst.name = TITLES[i]
		inst.position.y = i*130
		inst.connect("self_pressed", _on_pressed)
		inst.init_position()
		if i == TITLES.size()-1:
			inst.has_blue_coin = false
		elif i == 0:
			inst.grab_focus()
	for i in range(buttons.size()):
		if i == 0:
			buttons[i].focus_neighbor_bottom = buttons[i+1].get_path()
		elif i == buttons.size()-1:
			buttons[i].focus_neighbor_top = buttons[i-1].get_path()
		else:
			buttons[i].focus_neighbor_top = buttons[i-1].get_path()
			buttons[i].focus_neighbor_bottom = buttons[i+1].get_path()
			
	
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
	
	await tmenu.finished
	is_animating = false

func _input(_event: InputEvent) -> void:
	if Global.state != Global.States.MAIN_MENU or is_animating: return
	if Input.is_action_just_pressed("coin"):
		notif_man.show_notification("You have collected [color=#ffa506]%s coins!" % str(Global.coins_collected.size()))
	if Input.is_action_just_pressed("blue_coin"):
		notif_man.show_notification("You have collected [color=#0cb0ff]%s blue coins!" % str(Global.blue_coins_collected.size()))
