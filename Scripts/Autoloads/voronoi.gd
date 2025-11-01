extends Node

## Singleton for generating Voronoi diagrams
## Usage: Voronoi.generate_voronoi_cells(points, bounds)

## Generate Voronoi cells from a set of points within bounds
## Returns an array of polygons (each polygon is an Array[Vector2])
func generate_voronoi_cells(points: Array[Vector2], bounds: Rect2) -> Array:
	if points.size() == 0:
		return []
	
	var cells: Array = []
	
	# For each point, generate its Voronoi cell
	for i in range(points.size()):
		var cell = _compute_voronoi_cell(points[i], points, bounds)
		if cell.size() >= 3:  # Valid polygon
			cells.append(cell)
	
	return cells

## Compute a single Voronoi cell for a point
func _compute_voronoi_cell(center: Vector2, all_points: Array[Vector2], bounds: Rect2) -> Array[Vector2]:
	# Start with the bounding rectangle as the initial cell
	var cell_points: Array[Vector2] = [
		bounds.position,
		bounds.position + Vector2(bounds.size.x, 0),
		bounds.position + bounds.size,
		bounds.position + Vector2(0, bounds.size.y)
	]
	
	# For each other point, clip the cell by the perpendicular bisector
	for other in all_points:
		if other == center:
			continue
		
		cell_points = _clip_by_bisector(cell_points, center, other)
		
		if cell_points.size() < 3:
			break
	
	return cell_points

## Clip a polygon by a perpendicular bisector between two points
func _clip_by_bisector(polygon: Array[Vector2], p1: Vector2, p2: Vector2) -> Array[Vector2]:
	if polygon.size() < 3:
		return []
	
	# Midpoint between the two points
	var mid = (p1 + p2) / 2.0
	
	# Normal vector pointing toward p1
	var direction = (p2 - p1).normalized()
	var normal = Vector2(-direction.y, direction.x)
	
	var clipped: Array[Vector2] = []
	
	for i in range(polygon.size()):
		var current = polygon[i]
		var next = polygon[(i + 1) % polygon.size()]
		
		var current_side = _point_side(current, mid, normal)
		var next_side = _point_side(next, mid, normal)
		
		# Current point is on the "keep" side
		if current_side >= 0:
			clipped.append(current)
		
		# Edge crosses the bisector
		if current_side * next_side < 0:
			var intersection = _line_intersection(current, next, mid, normal)
			if intersection != null:
				clipped.append(intersection)
	
	return clipped

## Determine which side of a line a point is on
func _point_side(point: Vector2, line_point: Vector2, line_normal: Vector2) -> float:
	return (point - line_point).dot(line_normal)

## Find intersection of line segment with a line defined by point and normal
func _line_intersection(p1: Vector2, p2: Vector2, line_point: Vector2, line_normal: Vector2):
	var segment_dir = p2 - p1
	var denom = segment_dir.dot(line_normal)
	
	if abs(denom) < 0.0001:
		return null  # Parallel
	
	var t = (line_point - p1).dot(line_normal) / denom
	
	if t < 0.0 or t > 1.0:
		return null  # Intersection outside segment
	
	return p1 + segment_dir * t

## Helper function to generate random points within bounds
func generate_random_points(count: int, bounds: Rect2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i in count:
		points.append(Vector2(
			randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
			randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		))
	return points
