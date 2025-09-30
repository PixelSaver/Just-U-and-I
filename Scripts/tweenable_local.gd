extends Tweenable

func _ready() -> void:
	par = get_parent() as Control
	og_gl_pos = par.position
