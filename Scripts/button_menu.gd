extends Button
class_name ButtonMenu

signal self_pressed(val:ButtonMenu)
@export var has_blue_coin : bool = true
@export var button_border: Panel 
@export var button_text: RichTextLabel 
@export var button_bg: ColorRect 

@export var tween_duration : float = 0.2
@export var pos_offset : Vector2 = Vector2(70,0)
var original_pos : Vector2
@export var trans : Tween.TransitionType = Tween.TRANS_QUINT
@export var tween_ease : Tween.EaseType = Tween.EASE_OUT
@export var hbox : Control
@export var mouse_catch : Control

@onready var input_handler : InputHandler = $InputHandler

func init_position() -> void:
	original_pos = position
	mouse_catch.position = -pos_offset
	input_handler.connect("activated", manual_entered)
	input_handler.connect("deactivated", manual_exited)

func _gui_input(event: InputEvent) -> void:
	input_handler.manual_gui_input(event)

var hovered : Tween
func manual_entered() -> void:
	if unhovered != null: unhovered.kill()
	
	hovered = create_tween().set_trans(trans)
	hovered.set_parallel(true).set_ease(tween_ease)
	
	hovered.tween_property(button_border, "modulate", Color.BLACK, tween_duration)
	#hovered.tween_property(button_text, "modulate", Color.BLACK, tween_duration)
	hovered.tween_property(button_bg, "color", Color.WHITE, tween_duration)
	
	hovered.tween_property(self, "position", original_pos + pos_offset, tween_duration)
	mouse_catch.mouse_filter = Control.MOUSE_FILTER_PASS
	
	if unhovered:
		await unhovered.finished
		unhovered.kill()

var unhovered : Tween
func manual_exited() -> void:
	
	unhovered = create_tween().set_trans(trans)
	unhovered.set_parallel(true).set_ease(tween_ease)
	
	unhovered.tween_property(button_border, "modulate", Color.WHITE, tween_duration)
	#unhovered.tween_property(button_text, "modulate", Color.WHITE, tween_duration)
	unhovered.tween_property(button_bg, "color", Color.BLACK, tween_duration)

	unhovered.tween_property(self, "position", original_pos, tween_duration)
	await get_tree().process_frame
	mouse_catch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	await unhovered.finished
	unhovered.kill()

func _on_button_down() -> void:
	if has_blue_coin:
		Global.collect_blue_coin(self)
	self_pressed.emit(self)


func _on_button_up() -> void:
	pass # Replace with function body.

signal rejected
# Written with help from Claude AI
var is_reject_animating: bool = false

var rej_t : Tween
func reject_anim():
	if rej_t:
		rej_t.kill()
	rej_t = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	rej_t.tween_property(self, "modulate", Color.RED, 0.1)
	rej_t.tween_property(self, "modulate", Color.WHITE, 0.3)
	# Cancel any existing animation
	if is_reject_animating:
		is_reject_animating = false
		await get_tree().process_frame  # Wait for the old one to clean up
	
	is_reject_animating = true
	var spring_strength: float = 100.0
	var damping: float = 12.0
	var mass: float = 0.5
	var dir = [-1, 1][randi() % 2]
	var velocity: float = 1000.0 * dir
	var displacement: float = hbox.position.x  # Start from current position!
	var time: float = 0.0
	var duration: float = 1.5
	
	while time < duration and is_reject_animating:
		var delta = get_process_delta_time()
		
		var spring_force = -spring_strength * displacement
		var damping_force = -damping * velocity
		var acceleration = (spring_force + damping_force) / mass
		
		velocity += acceleration * delta
		displacement += velocity * delta
		
		hbox.position.x = displacement
		
		time += delta
		await get_tree().process_frame
	
	# Only reset if this animation wasn't cancelled
	if is_reject_animating:
		hbox.position.x = 0.0
		is_reject_animating = false
