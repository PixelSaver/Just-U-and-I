extends Tweenable

func _ready() -> void:
	pass

func manual_init():
	par = get_parent() as Control
	og_gl_pos = par.position
