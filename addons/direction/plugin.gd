@tool
extends EditorPlugin

var dir_inspector := DirectionInspectorPlugin.new()

func _enter_tree():
	add_inspector_plugin(dir_inspector)

func _exit_tree():
	remove_inspector_plugin(dir_inspector)
