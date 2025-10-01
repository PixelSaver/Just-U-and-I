extends Button
class_name Coin

signal collected(coin)

@export var anim_sprite : AnimatedSprite2D
@export var rigidbody : RigidBody2D
@export var follow_modulate : Node
@export var coin_id : String
@export var throw_dir : Vector2 = Vector2(1,1)
@export var coin_audio : AudioStreamPlayer
@export var coin_bounce : AudioStreamPlayer

var clicked : bool = false
var floor_dist : float = 200

func _ready():
	if coin_id in Global.coins_collected:
		queue_free()

func _on_collected():
	Global.coins_collected.append(coin_id)

func _on_pressed() -> void:
	disabled = true
	#top_level = true
	z_index += 1
	clicked = true
	_on_collected()
	collected.emit(self)
	#TODO Add coin collected notification and text saying +1
	coin_audio.play()
	
	var dur : float = 2
	
	#Global.root.add_child(rigidbody)
	rigidbody.freeze = false
	rigidbody.apply_central_impulse(throw_dir.normalized() * Vector2(1000,-20000))
	rigidbody.gravity_scale = 10
	
	anim_sprite.animation = "flip"
	anim_sprite.speed_scale = dur*3
	for i in range(3):
		anim_sprite.play()
		await anim_sprite.animation_finished
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "modulate:a", 0, 0.5)
	await t.finished
	queue_free()
	
func _process(delta: float) -> void:
	if follow_modulate:
		modulate.a = follow_modulate.modulate.a 
		if modulate.a != 1:
			disabled = true
		else:
			disabled = false

func _physics_process(delta: float) -> void:
	if not clicked: return
	if rigidbody.position.y > floor_dist:
		rigidbody.position.y = floor_dist
		rigidbody.linear_velocity.y = -abs(rigidbody.linear_velocity.y)
		if abs(rigidbody.linear_velocity.y) > 500 and !coin_bounce.playing:
			coin_bounce.volume_db = -30 + abs(rigidbody.linear_velocity.y)/100
			coin_bounce.play()
	
func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	pass # Replace with function body.
