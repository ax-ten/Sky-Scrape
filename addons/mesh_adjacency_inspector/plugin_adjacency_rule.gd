@tool
extends EditorInspectorPlugin
class_name PluginTiledAdjacencyRule

func _can_handle(object):
	return object is TiledAdjacencyRule

func _parse_begin(object):
	if object is TiledAdjacencyRule:
		var editor := EditorTiledAdjacencyRule.new()
		editor.setup(object)
		add_custom_control(editor)
