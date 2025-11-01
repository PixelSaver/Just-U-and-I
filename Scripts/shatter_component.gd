extends Node
class_name ShatterComponent

signal shatter_finished
@export var num_points := 20
@export var shatter_force := 150.0
@export var fade_time := 1.0
var par : Control

func _ready():
	randomize()
	par = get_parent() as Control

## Call this to trigger shattering for all ColorRect and Panel children
func shatter_all(node:Node=null):
	var targets
	if node: 
		targets = _find_shatterables(node)
	else:
		targets = _find_shatterables(par)
	for rect in targets:
		_shatter_colorrect(rect)



## find all ColorRects and Panels recursively
func _find_shatterables(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child is ColorRect or child is Panel:
			result.append(child)
		result.append_array(_find_shatterables(child))
	return result

func _shatter_colorrect(rect):
	var rect_global_pos = rect.position
	var rect_size = rect.size
	var rect_color: Color

	# Detect color for ColorRect or Panel
	if rect is ColorRect:
		rect_color = rect.color
	elif rect is Panel:
		var style = rect.get_theme_stylebox("panel")
		if style and style is StyleBoxFlat:
			rect_color = style.bg_color
		else:
			rect_color = Color.WHITE
	else:
		rect_color = Color.WHITE

	# Generate random points within the rectangle
	var bounds = Rect2(rect_global_pos, rect_size)
	var points: Array[Vector2] = Voronoi.generate_random_points(num_points, bounds)
	
	# Generate Voronoi cells
	var cells = Voronoi.generate_voronoi_cells(points, bounds)
	
	# Spawn a polygon for each Voronoi cell
	for cell in cells:
		_spawn_polygon(rect_global_pos, rect_color, cell)

	rect.visible = false

func _spawn_polygon(origin: Vector2, color: Color, poly_points: Array[Vector2]):
	var poly := Polygon2D.new()
	poly.polygon = poly_points
	poly.color = color
	poly.position = origin
	get_parent().add_child(poly)
	
	# Calculate centroid
	var centroid = Vector2.ZERO
	for p in poly_points:
		centroid += p
	centroid /= poly_points.size()
	
	# Direction from center of rect to centroid
	var rect_center = Vector2(poly.position.x, poly.position.y)
	var dir = (centroid - Vector2.ZERO).normalized()
	var speed = randf_range(shatter_force * 0.5, shatter_force)
	
	# Add some rotation
	var rotation_speed = randf_range(-3.0, 3.0)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(poly, "position", poly.position + dir * speed, fade_time)
	tween.tween_property(poly, "rotation", rotation_speed, fade_time)
	tween.tween_property(poly, "modulate:a", 0.0, fade_time)
	
	tween.chain().tween_callback(poly.queue_free)
	
	await tween.finished
	shatter_finished.emit()
