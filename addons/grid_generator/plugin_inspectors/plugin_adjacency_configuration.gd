@tool
extends EditorInspectorPlugin
class_name PluginAdjacencyConfiguration

var plug_box : VBoxContainer
var inspector : _MeshAdjacencyConfigurationInspector
var mapping = {
	"ClassAdjacencyConfiguration": ClassConfigurationInspector,
	"ModelAdjacencyConfiguration": ModelConfigurationInspector,
	"SimpleAdjacencyConfiguration": SimpleConfigurationInspector
}

func _can_handle(object: Object) -> bool:
	return object is _MeshAdjacencyConfiguration

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	var configuration = object
	if configuration is _MeshAdjacencyConfiguration:
		var meshlibrary = preload("res://Nodes/Palazzo/PalazzoMeshLibrary.tres")
		
		if configuration is SimpleAdjacencyConfiguration:
			inspector = SimpleConfigurationInspector.new()
		if configuration is ModelAdjacencyConfiguration:
			inspector = ModelConfigurationInspector.new()
		if configuration is ClassAdjacencyConfiguration:
			inspector = ClassConfigurationInspector.new()
			
		inspector.setup(configuration, meshlibrary)
		add_custom_control(inspector)
	return false
