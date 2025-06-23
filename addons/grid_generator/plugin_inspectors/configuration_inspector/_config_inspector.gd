extends VBoxContainer
class_name _MeshAdjacencyConfigurationInspector

# selector
# rule_editor

var selector
var rule_inspector : _RuleInspector

var config_object: _MeshAdjacencyConfiguration
var mesh_library: MeshLibrary
var white_border : CanvasItemMaterial = preload("res://Assets/Materiali/glowtext.tres")
var no_border := CanvasItemMaterial.new()

var uppercontainer : Container
var pickerbox := HBoxContainer.new()
var picker := EditorResourcePicker.new()
var picker_label := Label.new()


func _init() -> void:
	picker.toggle_mode = false
	picker.editable = true
	add_child(uppercontainer)
	add_child(pickerbox)
	add_child(rule_inspector)
	pickerbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pickerbox.add_child(picker_label)
	pickerbox.add_child(picker)
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
