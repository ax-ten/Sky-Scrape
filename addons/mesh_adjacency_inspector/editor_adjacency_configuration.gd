# File: addons/wfc_editor/editor_mesh_adjacency_view.gd
@tool
extends VBoxContainer
class_name EditorAdjacencyConfiguration

var config_object: MeshAdjacencyConfiguration
var mesh_library: MeshLibrary
var selected_id: int = -1

var white_border : CanvasItemMaterial = preload("res://Assets/Materiali/glowtext.tres")
var no_border := CanvasItemMaterial.new()

var rule_view := VBoxContainer.new()
var preview_buttons : Dictionary[int,TextureButton]= {}


func setup(_config_object: MeshAdjacencyConfiguration, _mesh_library: MeshLibrary) -> void:
	config_object = _config_object
	mesh_library = _mesh_library

	var grid := GridContainer.new()
	grid.columns = 6
	add_child(grid)

	# Popola griglia con le preview
	for mesh_id in mesh_library.get_item_list():
		var button := TextureButton.new()
		button.texture_normal = mesh_library.get_item_preview(mesh_id)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.connect("pressed", Callable(self, "_on_preview_pressed").bind(mesh_id))

		grid.add_child(button)
		preview_buttons[mesh_id] = button

	rule_view = VBoxContainer.new()
	add_child(rule_view)

func _on_preview_pressed(mesh_id: int) -> void:
	for id in preview_buttons:
		preview_buttons[id].material = no_border
	preview_buttons[mesh_id].material = white_border

	selected_id = mesh_id
	_update_rule_view()

func _update_rule_view() -> void:
	for child in rule_view.get_children():
		rule_view.remove_child(child)
		child.queue_free()

	# mostra id e nome della mesh selezionata
	var label := Label.new()
	var mesh_name := mesh_library.get_item_name(selected_id)
	label.text = "%d - %s" % [selected_id, mesh_name]
	rule_view.add_child(label)
	
	# crea un picker della risorsa
	var picker := EditorResourcePicker.new()
	picker.base_type = "TiledAdjacencyRule"
	picker.toggle_mode = true
	picker.editable = true
	
	# Se esiste già una regola assegnata, mostrala nel picker
	if config_object.rules.has(selected_id):
		picker.edited_resource = config_object.rules[selected_id]
	
	
	# apri l'editor della regola
	var rule_editor := EditorTiledAdjacencyRule.new()
	
	picker.resource_selected.connect(
		func(rule: TiledAdjacencyRule, inspect: bool):
			rule_editor.setup(rule)
			#DEBUG 
			#picker.edited_resource.changed.connect( func():
				#if str(rule) != '':
					#print("risorsa aggiornata\n " + str(rule))
			#)
	)
	picker.resource_changed.connect( 
		func (rule:TiledAdjacencyRule):
			config_object.rules[selected_id] = rule
			rule.emit_changed()
	)
		
	rule_view.add_child(picker)
	rule_view.add_child(rule_editor)
	
	
