extends Coin
class_name BlueCoin

@onready var parent : Node = get_parent()
@onready var par_name : String = coin_id + parent.name

func _ready() -> void:
	anim_sprite.modulate.a = 0

func interacted_with():
	anim_sprite.modulate.a = 1
	throw_dir.x = randf_range(-1,1)
	_on_pressed()
