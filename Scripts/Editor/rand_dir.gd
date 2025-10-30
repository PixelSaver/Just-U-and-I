@tool
extends EditorScript

func _run():
	randomize_all_tweenable_directions()

func randomize_all_tweenable_directions():
	var scene_root = get_scene()
	var all_nodes = get_all_children(scene_root)
	
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Randomize Tweenable Directions")
	
	for node in all_nodes:
		if node is Tweenable:
			var old_dir = node.dir
			var new_dir = get_random_dir()
			
			undo_redo.add_do_property(node, "dir", new_dir)
			undo_redo.add_undo_property(node, "dir", old_dir)
			
			print("Randomized ", node.name, " dir to: ", new_dir)
	
	undo_redo.commit_action()

var dirs = [Vector2(-1,-1), Vector2(1,1)]
func get_random_dir():
	return dirs[randi_range(0, dirs.size()-1)]

func get_all_children(node):
	var nodes = []
	for child in node.get_children():
		nodes.append(child)
		nodes += get_all_children(child)
	return nodes
