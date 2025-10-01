@tool
extends EditorScript
var child_scene : PackedScene = preload("res://Scenes/tweenable.tscn")

func _run() -> void:
	randomize()  # ensure randi()/randf() produce different values
	
	var editor := get_editor_interface()
	var selection: Array = editor.get_selection().get_selected_nodes()
	var root := editor.get_edited_scene_root()
	var undo_redo = editor.get_editor_undo_redo()
	
	if selection.is_empty():
		return
	
	if root == null:
		return
	
	var children = []
	
	# Create all children first
	for parent in selection:
		if parent is Node:
			# Instance the child
			var child = child_scene.instantiate()
			child.name = "Tweenable_%s" % str(randi() % 1000)
			
			# Randomize export vars
			#var dirs = [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
			var dirs = [Vector2(1,1), Vector2(-1,-1)]
			child.dir = dirs[randi_range(0, dirs.size()-1)]
			child.speed = pow(randf(), 4) * 12
			
			children.append({"parent": parent, "child": child})
	
	# Now register with undo/redo
	undo_redo.create_action("Add randomized children to selection")
	
	for item in children:
		var parent = item.parent
		var child = item.child
		
		undo_redo.add_do_method(parent, "add_child", child)
		undo_redo.add_do_method(child, "set_owner", root)
		undo_redo.add_do_reference(child)
		
		undo_redo.add_undo_method(parent, "remove_child", child)
		undo_redo.add_undo_reference(child)
	
	# Finalize the action
	undo_redo.commit_action()
	print("Tweenable Script completed")
