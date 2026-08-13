@tool
class_name NPConsoleScript
extends EditorScript

func selected_nodes() -> Array[Node]:
	return get_editor_interface().get_selection().get_selected_nodes()

func reparent_selected() -> bool:
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
