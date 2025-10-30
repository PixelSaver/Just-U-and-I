extends Node
class_name ShatterComponent

@export var num_points := 20
@export var shatter_force := 150.0
@export var fade_time := 1.0
var par : Control

func _ready():
	randomize()
	par = get_parent() as Control

## Call this to trigger shattering for all ColorRect and Panel children
func shatter_all():
	var targets = _find_shatterables(par)
	print(targets)
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

	var points: Array[Vector2] = []
	var rect_area = Rect2(Vector2.ZERO, rect_size)
	points.append(rect_area.position)
	points.append(rect_area.position + Vector2(rect_area.size.x, 0))
	points.append(rect_area.position + Vector2(0, rect_area.size.y))
	points.append(rect_area.position + rect_area.size)

	for i in num_points:
		points.append(Vector2(randf_range(0, rect_size.x), randf_range(0, rect_size.y)))

	for i in range(points.size() / 3.):
		var tri: Array[Vector2] = []
		for j in range(3):
			tri.append(points.pick_random())
		_spawn_triangle(rect_global_pos, rect_color, tri)

	rect.visible = false

func _spawn_triangle(origin: Vector2, color: Color, tri_points: Array[Vector2]):
	var poly := Polygon2D.new()
	poly.polygon = tri_points
	poly.color = color
	poly.position = origin
	get_parent().add_child(poly)

	var centroid = (tri_points[0] + tri_points[1] + tri_points[2]) / 3.0
	var dir = (centroid - Vector2.ZERO).normalized()
	var speed = randf_range(shatter_force * 0.5, shatter_force)

	var tween = get_tree().create_tween()
	tween.tween_property(poly, "position", poly.position + dir * speed, fade_time)
	tween.tween_property(poly, "modulate:a", 0.0, fade_time)
	tween.tween_callback(poly.queue_free)
