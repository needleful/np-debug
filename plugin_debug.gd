@tool
class_name NPDebugPlugin
extends EditorPlugin

var ecscn = preload('res://addons/np-debug/editor_console.tscn')
var editor_console: Control

func _enter_tree():
	if not editor_console:
		editor_console = ecscn.instantiate()
	add_control_to_bottom_panel(editor_console, 'Console')

func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor_console)
