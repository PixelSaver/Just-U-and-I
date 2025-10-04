extends Button
class_name EndButton1

@export var bg_1 : Control
@export var bg_2 : Control
var t : Tween

func _ready():
	
	pivot_offset = size / 2
	bg_1.pivot_offset = bg_1.size / 2
	bg_2.pivot_offset = bg_2.size / 2
	

func _on_mouse_entered() -> void:
	var dur = 0.2
	t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_ease(Tween.EASE_OUT).set_parallel(true)
	t.tween_property(bg_1, "scale", Vector2.ONE * 0.95, dur)
	t.tween_property(bg_2, "scale", Vector2.ONE * 1.05, dur)


func _on_mouse_exited() -> void:
	var dur = 0.2
	t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_ease(Tween.EASE_OUT).set_parallel(true)
	t.tween_property(bg_1, "scale", Vector2.ONE, dur)
	t.tween_property(bg_2, "scale", Vector2.ONE, dur)


func _on_pressed() -> void:
	var dur = 0.2
	t = create_tween().set_trans(Tween.TRANS_QUINT)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 0.7, dur/2)
	t.tween_property(self, "modulate:a", 1., dur/2)
