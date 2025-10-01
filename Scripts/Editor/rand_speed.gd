@tool
extends EditorScript

func _run():
	randomize_all_tweenable_speeds()

var all_nodes = []
func randomize_all_tweenable_speeds():
	var scene_root = get_scene()
	var selection: Array = get_editor_interface().get_selection().get_selected_nodes()
	if selection.size() == 0:
		all_nodes = get_all_children(scene_root)
	else:
		for node in selection:
			all_nodes.append(node.get_children()[0])
	
	var undo_redo = get_editor_interface().get_editor_undo_redo()
	undo_redo.create_action("Randomize Tweenable Speeds")
	
	for node in all_nodes:
		if node is Tweenable:
			var old_speed = node.speed
			var new_speed = get_random_speed()
			
			undo_redo.add_do_property(node, "speed", new_speed)
			undo_redo.add_undo_property(node, "speed", old_speed)
			
			print("Randomized ", node.name, " speed to: ", new_speed)
	
	undo_redo.commit_action()

func get_random_speed():
	#return pow(randf(), 6) * 20
	return randf_range(1, 7)

func get_all_children(node):
	var nodes = []
	for child in node.get_children():
		nodes.append(child)
		nodes += get_all_children(child)
	return nodes
