@tool
extends EditorInspectorPlugin
class_name DirectionInspectorPlugin
const AXIS_LABELS := ["x", "y", "z"]
const AXIS_COLORS := [Color.PALE_VIOLET_RED, Color.MEDIUM_SEA_GREEN, Color.MEDIUM_PURPLE]

func _can_handle(object):
	return true

static func vector_editor(dir) -> HBoxContainer:
	var vector_container := HBoxContainer.new()
		# Nome (non modificabile)
	var label := Label.new()
	label.text = dir.name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	vector_container.add_child(label)
	for j in Direction3D.cardinality:
		# Label con la lettera colorata (X/Y/Z)
		var axis_label := Label.new()
		axis_label.text = AXIS_LABELS[j]
		axis_label.add_theme_color_override("font_color", AXIS_COLORS[j])
		axis_label.size_flags_horizontal = Control.SIZE_FILL
		axis_label.custom_minimum_size = Vector2(10, 0)
		
		var spin := SpinBox.new()
		spin.min_value = -100
		spin.max_value = 100
		spin.step = 1
		spin.value = dir.vector[j]
		#spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		

		spin.connect("value_changed", func(val):
			var v = dir.vector
			v[j] = int(val)
			dir.vector = v
			dir.emit_changed()
		)
		
		vector_container.add_child(axis_label)
		vector_container.add_child(spin)
	return vector_container


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	var value = object.get(name)
	if type == TYPE_ARRAY and value.size()>0 and value[0] is Direction3D:#or type != TYPE_ARRAY:
		var directions: Array = object.get(name)
		var list_container := VBoxContainer.new()
		for direction in value:
			list_container.add_child(vector_editor(direction))
		add_property_editor(name, list_container)
		return true
		
	elif value is Direction3D:
		var direction: Array = object.get(name)
		add_property_editor(name, vector_editor(direction))
		return true
		
		
	return false
