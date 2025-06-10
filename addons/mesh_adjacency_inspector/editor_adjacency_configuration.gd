# File: addons/wfc_editor/editor_mesh_adjacency_view.gd
@tool
extends VBoxContainer
class_name EditorAdjacencyConfiguration

var config_object: MeshAdjacencyConfiguration
var mesh_library: MeshLibrary
var selected_id: int = 0

var white_border : CanvasItemMaterial = preload("res://Assets/Materiali/glowtext.tres")
var no_border := CanvasItemMaterial.new()

var rule_view := VBoxContainer.new()
var preview_buttons : Dictionary[int,TextureButton]= {}

var grid := GridContainer.new()
var label := Label.new()
var picker := EditorResourcePicker.new()
var rule_editor := EditorTiledAdjacencyRule.new()

func _init() -> void:
	grid.columns = 6
	
	picker.base_type = "TiledAdjacencyRule"
	picker.toggle_mode = false
	picker.editable = true
	
	add_child(grid)
	add_child(rule_view)
	rule_view.add_child(label)
	rule_view.add_child(picker)
	rule_view.add_child(rule_editor)

func setup(_config_object: MeshAdjacencyConfiguration, _mesh_library: MeshLibrary) -> void:
	config_object = _config_object
	mesh_library = _mesh_library

	# Popola griglia con le preview
	for mesh_id in mesh_library.get_item_list():
		var button := TextureButton.new()
		button.texture_normal = mesh_library.get_item_preview(mesh_id)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.connect("pressed", Callable(self, "_on_preview_pressed").bind(mesh_id))
		grid.add_child(button)
		preview_buttons[mesh_id] = button
	
	picker.resource_selected.connect(
		func(rule: TiledAdjacencyRule, inspect: bool):
			rule_editor.setup(rule)
	)
	picker.resource_changed.connect( 
		func (rule:TiledAdjacencyRule):
			config_object.rules[selected_id] = rule
			rule_editor.setup(rule)
	)

func _on_preview_pressed(selected_id: int) -> void:
	self.selected_id = selected_id
	# visually update grid
	for id in preview_buttons:
		preview_buttons[id].material = no_border
	preview_buttons[selected_id].material = white_border
	# setup selected rule, if any
	var selected_rule : TiledAdjacencyRule = config_object.rules.get(selected_id, null)
	rule_editor.setup(selected_rule)
	picker.edited_resource = selected_rule
	
	# mostra id e nome della mesh selezionata
	label.text = "%d - %s" % [selected_id, mesh_library.get_item_name(selected_id)]

	
	
