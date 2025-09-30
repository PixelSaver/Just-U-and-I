extends Node2D
class_name NotificationManagerMenu

@export var notification_scene: PackedScene  
@export var spacing: float = 10
@export var fade_duration: float = 0.5
@export var display_duration: float = 3.0

var notification_queue: Array[Node2D] = []

func _ready():
	pass

func show_notification(message: String):
	var notif = notification_scene.instantiate() 
	
	if notification_scene:
		notif.get_node("Label").text = message
	
	add_child(notif)
	notification_queue.append(notif)
	
	_update_positions()
	
	notif.modulate.a = 0.0
	var fade_in = create_tween()
	fade_in.tween_property(notif, "modulate:a", 1.0, fade_duration)
	await fade_in.finished
	
	await get_tree().create_timer(display_duration).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property(notif, "modulate:a", 0.0, fade_duration)
	await fade_out.finished
	
	notification_queue.erase(notif)
	notif.queue_free()
	_update_positions()

func _update_positions():
	var y_offset = 0.0
	for i in range(notification_queue.size() - 1, -1, -1):
		var notif = notification_queue[i]
		var target_y = -y_offset
		var tween = create_tween()
		tween.tween_property(notif, "position:y", target_y, 0.3)
		y_offset += notif.get_node("Control").size.y + spacing
