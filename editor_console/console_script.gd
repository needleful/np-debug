@tool
class_name NPConsoleScript
extends EditorScript

func node(path: String) -> Node:
	return get_scene().get_node(path)

func nodes_where(c: Callable) -> Array[Node]:
	return _recursive_search(get_scene(), c)

func _recursive_search(node: Node, c: Callable, r: Array[Node] = []) -> Array[Node]:
	if c.call(node):
		r.append(node)
	for child in node.get_children():
		_recursive_search(child, c, r)
	return r
