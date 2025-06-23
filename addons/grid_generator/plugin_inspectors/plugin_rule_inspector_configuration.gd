@tool
extends EditorInspectorPlugin
class_name PluginRuleInspector

var plug_box : VBoxContainer
var inspector : _RuleInspector


func _can_handle(object: Object) -> bool:
	return object is _AdjacencyRule

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if object is _AdjacencyRule:
		var rule = object
		if rule is TiledAdjacencyRule:
			inspector = SimpleRuleInspector.new()
		if rule is ModelAdjacencyRule:
			inspector = ModelRuleInspector.new()
		if rule is ClassAdjacencyRule:
			inspector = ClassRuleInspector.new()
		inspector.setup(rule)
		add_custom_control(inspector)
	return false
