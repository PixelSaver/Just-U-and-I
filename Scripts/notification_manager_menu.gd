extends Node2D
class_name NotificationManagerMenu

@export var notification_scene: PackedScene  
@export var spacing: float = 25
@export var fade_duration: float = 0.5
@export var display_duration: float = 200.0


var notification_queue: Array[Node2D] = []

func _ready():
	pass

func show_notification(message: String):
	if not notification_scene: return
	var notif = notification_scene.instantiate() 
	var label = notif.get_node("Label") as RichTextLabel
	
	add_child(notif)
	notification_queue.append(notif)
	
	# Update notification size
	label.clear() 
	label.append_text(message)
	label.reset_size()
	var size_x = label.size.x
	print("size %s" % size_x)
	notif.get_node("Control").size.x = size_x + 40
	notif.position.x = -notif.get_node("Label").size.x + 265
	
	for tween in all_tweenables(notif):
		tween.manual_init()
	
	_update_positions()
	
	notif.modulate.a = 0.0
	var fade_in = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true).set_ease(Tween.EASE_OUT)
	var all_t : Array[Tweenable] = all_tweenables(notif)
	for tween in all_t:
		tween.get_parent().position = tween.get_final_pos()
		fade_in.tween_property(tween.get_parent(), "position", tween.og_gl_pos, fade_duration)
	fade_in.tween_property(notif, "modulate:a", 1.0, fade_duration)
	await fade_in.finished
	
	
	
	await get_tree().create_timer(display_duration).timeout
	
	var fade_out = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	for tween in all_t:
		fade_out.tween_property(tween.get_parent(), "position", tween.get_final_pos(), fade_duration)
	fade_out.tween_property(notif, "modulate:a", 0.0, fade_duration)
	await fade_out.finished
	
	notification_queue.erase(notif)
	notif.queue_free()
	_update_positions()

func all_tweenables(notif:Node2D) -> Array[Tweenable]:
	var out : Array[Tweenable] = []
	for child in notif.get_node("Control").get_children():
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

func _update_positions():
	var y_offset = 0.0
	for i in range(notification_queue.size() - 1, -1, -1):
		var notif = notification_queue[i]
		var target_y = -y_offset
		var tween = create_tween()
		tween.tween_property(notif, "position:y", target_y, 0.3)
		y_offset += notif.get_node("Control").size.y + spacing
