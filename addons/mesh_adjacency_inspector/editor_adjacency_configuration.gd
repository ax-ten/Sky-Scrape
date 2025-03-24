# File: addons/wfc_editor/editor_mesh_adjacency_view.gd
@tool
extends VBoxContainer
class_name EditorAdjacencyConfiguration

var config_object: MeshAdjacencyConfiguration
var mesh_library: MeshLibrary
var selected_id: int = -1
var white_border = StyleBoxFlat.new()
var no_border = StyleBoxFlat.new()

var rule_view := VBoxContainer.new()
var preview_buttons : Dictionary[int,TextureButton]= {}

func _ready() -> void:
	white_border.border_color = Color.WHITE
	white_border.set_border_width_all(2)

func setup(_config_object: MeshAdjacencyConfiguration, _mesh_library: MeshLibrary) -> void:
	config_object = _config_object
	mesh_library = _mesh_library

	var grid := GridContainer.new()
	grid.columns = 6
	add_child(grid)

	for mesh_id in mesh_library.get_item_list():
		var icon := mesh_library.get_item_preview(mesh_id)

		var button := TextureButton.new()
		button.texture_normal = icon
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.connect("pressed", Callable(self, "_on_preview_pressed").bind(mesh_id))

		grid.add_child(button)
		preview_buttons[mesh_id] = button

	rule_view = VBoxContainer.new()
	add_child(rule_view)

func _on_preview_pressed(mesh_id: int) -> void:
	for id in preview_buttons:
		preview_buttons[id].theme = no_border
		#preview_buttons[id].remove_theme_stylebox("normal")
	preview_buttons[mesh_id].theme = white_border

	selected_id = mesh_id
	_update_rule_view()

func _update_rule_view() -> void:
	for child in rule_view.get_children():
		rule_view.remove_child(child)
		child.queue_free()

	if not config_object.rules.has(selected_id):
		return

	var label := Label.new()
	var mesh_name := mesh_library.get_item_name(selected_id)
	label.text = "%d - %s" % [selected_id, mesh_name]
	rule_view.add_child(label)
	
	var picker := EditorResourcePicker.new()
	picker.base_type = "AdjacencyRule"
	picker.toggle_mode = true
	var rule_editor := EditorAdjacencyRule.new()
	rule_editor.setup(config_object.rules[selected_id])
	rule_editor.visible = false
	rule_view.add_child(rule_editor)
	picker.resource_selected.connect(func():
		rule_editor.visible = true
	)
	picker.edited_resource = config_object.rules[selected_id]
	rule_view.add_child(picker)
	
	
