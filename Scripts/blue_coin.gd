extends Coin
class_name BlueCoin

@onready var parent : Node = get_parent()
@onready var par_name : String = parent.name

func _ready() -> void:
	if par_name in Global.blue_coins_collected:
		disabled = true
		modulate.a = 0
		anim_sprite.modulate.a = 0
		#queue_free()

func interacted_with():
	if par_name in Global.blue_coins_collected: return
	throw_dir.x = randf_range(-1,1)
	_on_pressed()

func _on_collected():
	Global.blue_coins_collected.append(par_name)
	print(Global.blue_coins_collected)
