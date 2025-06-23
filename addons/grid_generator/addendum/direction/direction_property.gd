@tool
extends EditorInspectorPlugin
class_name DirectionInspectorPlugin
const AXIS_LABELS := ["x", "y", "z"]
const AXIS_COLORS := [Color.PALE_VIOLET_RED, Color.MEDIUM_SEA_GREEN, Color.MEDIUM_PURPLE]

func _can_handle(object):
	return true

static func vector_editor(direction_name, direction_values) -> HBoxContainer:
	var vector_container := HBoxContainer.new()
		# Nome (non modificabile)
	var label := Label.new()
	label.text = direction_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	vector_container.add_child(label)
	for j in 3:
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
		spin.value = direction_values[j]
		#spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		

		spin.connect("value_changed", func(val):
			direction_values[j] = int(val)
		)
		
		vector_container.add_child(axis_label)
		vector_container.add_child(spin)
	return vector_container


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	var value = object.get(name)
	
	if type == TYPE_ARRAY and value[0] is Direction3D:
		var list_container := VBoxContainer.new()
		for e in value:
			list_container.add_child(vector_editor(e.name, e.vector))
		add_property_editor(name, list_container)
		return true
	
	if value and type == TYPE_DICTIONARY and value.values()[0] is Vector3i:
		var directions = object.get(name).keys()
		var list_container := VBoxContainer.new()
		for vector_name in directions:
			var xyz = [
				value[vector_name].x, 
				value[vector_name].y, 
				value[vector_name].z
				]
			list_container.add_child(vector_editor(vector_name, xyz ))
		add_property_editor(name, list_container)
		return true
		
	elif value is Direction3D:
		add_property_editor(name, vector_editor(value.name, value.vector))
		return true
		
		
	return false
