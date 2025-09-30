@tool
extends EditorScript

func _run():
	randomize_all_tweenable_speeds()

func randomize_all_tweenable_speeds():
	var scene_root = get_scene()
	var all_nodes = get_all_children(scene_root)
	
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
	return pow(randf(), 2) * 20

func get_all_children(node):
	var nodes = []
	for child in node.get_children():
		nodes.append(child)
		nodes += get_all_children(child)
	return nodes
