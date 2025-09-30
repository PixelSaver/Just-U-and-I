extends Button
class_name ButtonMenu

signal self_pressed(val:ButtonMenu)
@export var button_border: Panel 
@export var button_text: RichTextLabel 
@export var button_bg: ColorRect 

@export var tween_duration : float = 0.2
@export var pos_offset : Vector2 = Vector2(70,0)
var original_pos : Vector2
@export var trans : Tween.TransitionType = Tween.TRANS_QUINT
@export var tween_ease : Tween.EaseType = Tween.EASE_OUT
@export var hbox : Control

func _ready() -> void:
	await get_tree().get_first_node_in_group("MainMenu").ready
	original_pos = position

var hovered : Tween
func _on_mouse_entered() -> void:
	#TODO Fix the fact that you can have the button go into a seizure when you hover in the right area (tweened away from but then exits)
	if unhovered != null: unhovered.kill()
	
	hovered = create_tween().set_trans(trans)
	hovered.set_parallel(true).set_ease(tween_ease)
	
	hovered.tween_property(button_border, "modulate", Color.BLACK, tween_duration)
	#hovered.tween_property(button_text, "modulate", Color.BLACK, tween_duration)
	hovered.tween_property(button_bg, "color", Color.WHITE, tween_duration)
	
	hovered.tween_property(self, "position", original_pos + pos_offset, tween_duration)
	#size = Vector2(400,110) + pos_offset
	#hbox.position = pos_offset
	#hovered.tween_property(self, "size", size + pos_offset, tween_duration)
	#hovered.tween_property(hbox, "position", pos_offset*2, tween_duration)

var unhovered : Tween
func _on_mouse_exited() -> void:
	
	unhovered = create_tween().set_trans(trans)
	unhovered.set_parallel(true).set_ease(tween_ease)
	
	unhovered.tween_property(button_border, "modulate", Color.WHITE, tween_duration)
	#unhovered.tween_property(button_text, "modulate", Color.WHITE, tween_duration)
	unhovered.tween_property(button_bg, "color", Color.BLACK, tween_duration)

	unhovered.tween_property(self, "position", original_pos, tween_duration)
	#size = Vector2(400,110)
	hbox.position = Vector2.ZERO
	#unhovered.tween_property(self, "size", Vector2(400,110), tween_duration)
	#unhovered.tween_property(hbox, "position", Vector2.ZERO, tween_duration)
	
	await unhovered.finished
	unhovered.kill()

func _on_button_down() -> void:
	self_pressed.emit(self)


func _on_button_up() -> void:
	pass # Replace with function body.

# Written with help from Claude AI
func reject_anim():
	# Spring parameters
	var spring_strength: float = 200.0
	var damping: float = 12.0
	var mass: float = 1.0
	
	# Initial impulse (throw the button)
	var throw_distance: float = 30.0  # How far to throw it
	var velocity: float = throw_distance * 50.0  # Initial velocity
	var displacement: float = 0.0
	var rest_x: float = 0.0  # Original x position
	
	# Store original position
	var original_pos = button_bg.position
	
	# Spring simulation loop
	var time: float = 0.0
	var duration: float = 1.5  # Total animation time
	
	while time < duration:
		var delta = get_process_delta_time()
		
		# Spring physics
		var spring_force = -spring_strength * (displacement - rest_x)
		var damping_force = -damping * velocity
		var acceleration = (spring_force + damping_force) / mass
		
		velocity += acceleration * delta
		displacement += velocity * delta
		
		# Apply to button_bg
		button_bg.position.x = original_pos.x + displacement
		
		time += delta
		await get_tree().process_frame
	
	# Ensure it ends at rest position
	button_bg.position = original_pos
