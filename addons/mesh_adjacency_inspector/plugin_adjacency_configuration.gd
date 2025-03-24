@tool
extends EditorInspectorPlugin
class_name PluginAdjacencyConfiguration

var mesh_library := preload("res://PalazzoMeshLibrary.tres")

func _can_handle(object: Object) -> bool:
	return object is MeshAdjacencyConfiguration

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "rules":
		if object.rules.is_empty():
			for mesh_id in mesh_library.get_item_list():
				object.rules[mesh_id] = AdjacencyRule.new()
			object.rules = object.rules.duplicate(true)

		var custom_ui := EditorAdjacencyConfiguration.new()
		custom_ui.setup(object, mesh_library)
		add_custom_control(custom_ui)
		return true
	return false

#func _parse_begin(object: Object) -> void:
	#if object.rules.is_empty():
		#for mesh_id in mesh_library.get_item_list():
			#object.rules[mesh_id] = AdjacencyRule.new()
		#object.property_list_changed_notify()
#
	#var main_ui := EditorAdjacencyConfiguration.new()
	#main_ui.setup(object, mesh_library)
	#add_custom_control(main_ui)
