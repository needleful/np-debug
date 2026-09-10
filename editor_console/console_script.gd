@tool
class_name NPConsoleScript
extends EditorScript

func selected_nodes() -> Array[Node]:
	return get_editor_interface().get_selection().get_selected_nodes()

func reparent() -> bool:
	var s := selected_nodes()
	if s.is_empty():
		return false
	var last := selected_nodes().pop_back()
	for node in s:
		node.reparent(last)
	return true

func node(path: String) -> Node:
	return get_scene().get_node(path)

func nodes_where(c: Callable) -> Array[Node]:
	return _recursive_search(get_scene(), c)

func name_is(node: Node, s: String):
	return node.name == s

func _recursive_search(node: Node, c: Callable, r: Array[Node] = []) -> Array[Node]:
	if c.call(node):
		r.append(node)
	for child in node.get_children():
		_recursive_search(child, c, r)
	return r

func _set_owner_recursive(p_node: Node, p_from: Node, p_owner: Node):
	if p_node.owner == p_from:
		p_node.owner = p_owner
	for c in p_node.get_children():
		_set_owner_recursive(c, p_from, p_owner)

func filesystem() -> EditorFileSystem:
	return EditorInterface.get_resource_filesystem()

func reimport_all(ext: String):
	var files := files_by_extension(ext)
	filesystem().reimport_files(files)
	return files
# Based on code by hiulit
# https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e
func files_by_extension(file_ext: String, root := "res://") -> Array:
	var dir := DirAccess.open(root)

	if not dir:
		print("An error occurred when trying to access %s." % root)
		return []

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var result := []
	while file_name:
		if dir.current_is_dir():
			result.append_array(files_by_extension(file_ext,
				dir.get_current_dir() + '/'+file_name))
		else:
			if file_ext and file_name.get_extension() != file_ext:
				file_name = dir.get_next()
				continue
			result.append(file_name)
		file_name = dir.get_next()
	return result
