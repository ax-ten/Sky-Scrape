@tool
extends EditorInspectorPlugin
class_name PluginAdjacencyRule

func _can_handle(object):
	return object is AdjacencyRule

func _parse_begin(object):
	if object is AdjacencyRule:
		var editor := EditorAdjacencyRule.new()
		editor.setup(object)
		add_custom_control(editor)
