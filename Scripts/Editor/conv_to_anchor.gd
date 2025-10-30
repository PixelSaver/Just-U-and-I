@tool
extends EditorScript

# Written with the help of Claude AI

func _run():
	# Get the editor selection and undo/redo
	# var editor_interface = get_editor_interface()
	var selection = EditorInterface.get_selection()
	var selected_nodes = selection.get_selected_nodes()
	var undo_redo = EditorInterface.get_editor_undo_redo()
	
	if selected_nodes.is_empty():
		print("No nodes selected!")
		return
	
	# Filter only Control nodes
	var control_nodes = []
	for node in selected_nodes:
		if node is Control:
			control_nodes.append(node)
		else:
			print("Skipping non-Control node: ", node.name)
	
	if control_nodes.is_empty():
		print("No Control nodes selected!")
		return
	
	# Create an undo/redo action
	undo_redo.create_action("Convert Control Nodes to Anchor Mode")
	
	for control in control_nodes:
		convert_to_anchor_mode_undoable(control, undo_redo)
	
	# Commit the action
	undo_redo.commit_action()
	
	print("Converted ", control_nodes.size(), " Control node(s) to anchor mode (Ctrl+Z to undo)")

func convert_to_anchor_mode_undoable(control: Control, undo_redo: EditorUndoRedoManager):
	# Get the parent to calculate relative positions
	var parent = control.get_parent()
	
	if not parent is Control:
		print("Warning: ", control.name, " parent is not a Control node. Skipping.")
		return
	
	# Get parent size
	var parent_size = parent.size
	
	if parent_size.x == 0 or parent_size.y == 0:
		print("Warning: Parent size is zero for ", control.name, ". Using fallback.")
		parent_size = Vector2(1, 1)
	
	# Store current position and size
	var current_pos = control.position
	var current_size = control.size
	
	# Store old values for undo
	var old_anchor_left = control.anchor_left
	var old_anchor_top = control.anchor_top
	var old_anchor_right = control.anchor_right
	var old_anchor_bottom = control.anchor_bottom
	var old_offset_left = control.offset_left
	var old_offset_top = control.offset_top
	var old_offset_right = control.offset_right
	var old_offset_bottom = control.offset_bottom
	var old_grow_h = control.grow_horizontal
	var old_grow_v = control.grow_vertical
	
	# Calculate new anchor positions (0.0 to 1.0 range)
	var new_anchor_left = current_pos.x / parent_size.x
	var new_anchor_top = current_pos.y / parent_size.y
	var new_anchor_right = (current_pos.x + current_size.x) / parent_size.x
	var new_anchor_bottom = (current_pos.y + current_size.y) / parent_size.y
	
	# Add undo/redo operations for each property
	undo_redo.add_do_property(control, "anchor_left", new_anchor_left)
	undo_redo.add_do_property(control, "anchor_top", new_anchor_top)
	undo_redo.add_do_property(control, "anchor_right", new_anchor_right)
	undo_redo.add_do_property(control, "anchor_bottom", new_anchor_bottom)
	undo_redo.add_do_property(control, "offset_left", 0)
	undo_redo.add_do_property(control, "offset_top", 0)
	undo_redo.add_do_property(control, "offset_right", 0)
	undo_redo.add_do_property(control, "offset_bottom", 0)
	undo_redo.add_do_property(control, "grow_horizontal", Control.GROW_DIRECTION_BOTH)
	undo_redo.add_do_property(control, "grow_vertical", Control.GROW_DIRECTION_BOTH)
	
	undo_redo.add_undo_property(control, "anchor_left", old_anchor_left)
	undo_redo.add_undo_property(control, "anchor_top", old_anchor_top)
	undo_redo.add_undo_property(control, "anchor_right", old_anchor_right)
	undo_redo.add_undo_property(control, "anchor_bottom", old_anchor_bottom)
	undo_redo.add_undo_property(control, "offset_left", old_offset_left)
	undo_redo.add_undo_property(control, "offset_top", old_offset_top)
	undo_redo.add_undo_property(control, "offset_right", old_offset_right)
	undo_redo.add_undo_property(control, "offset_bottom", old_offset_bottom)
	undo_redo.add_undo_property(control, "grow_horizontal", old_grow_h)
	undo_redo.add_undo_property(control, "grow_vertical", old_grow_v)
	
	print("Converted ", control.name, " - Anchors: L:", new_anchor_left, " T:", new_anchor_top, " R:", new_anchor_right, " B:", new_anchor_bottom)
