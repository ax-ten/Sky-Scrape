@tool
extends _MeshAdjacencyConfigurationInspector
class_name SimpleConfigurationInspector

var selected_id: int = -1
var preview_buttons : Dictionary[int,TextureButton]= {}


#var rule_editor := EditorTiledAdjacencyRule.new()

func _init() -> void:
	uppercontainer = GridContainer.new()
	uppercontainer.columns = 6
	rule_inspector = SimpleRuleInspector.new()
	#rule_inspector.visible = false
	
	picker.base_type = "TiledAdjacencyRule"
	picker_label.text = "Seleziona una mesh"
	picker.visible = false
	super._init()
	


func setup(_config_object: SimpleAdjacencyConfiguration, _mesh_library: MeshLibrary) -> void:
	config_object = _config_object
	mesh_library = _mesh_library

	# Popola griglia con le preview
	for mesh_id in mesh_library.get_item_list():
		var button := TextureButton.new()
		button.texture_normal = mesh_library.get_item_preview(mesh_id)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.connect("pressed", Callable(self, "_on_preview_pressed").bind(mesh_id))
		uppercontainer.add_child(button)
		preview_buttons[mesh_id] = button

	
	picker.resource_selected.connect(
		func(rule: TiledAdjacencyRule, inspect: bool):
			rule_inspector.setup(rule)
			#rule_inspector.visible = true
	)
	picker.resource_changed.connect( 
		func (rule:TiledAdjacencyRule):
			config_object.rules[selected_id] = rule
			rule_inspector.setup(rule)
			#rule_inspector.visible = true
	)

func _on_preview_pressed(selected_id: int) -> void:
	self.selected_id = selected_id
	picker.visible = true
	
	# visually update grid
	for id in preview_buttons:
		preview_buttons[id].material = no_border
	preview_buttons[selected_id].material = white_border
	# setup selected rule, if any
	
	var selected_rule : TiledAdjacencyRule = config_object.rules.get(selected_id, null)
	
	rule_inspector.setup(selected_rule)
	picker.edited_resource = selected_rule
	
	# mostra id e nome della mesh selezionata
	picker_label.text = "%d - %s" % [selected_id, mesh_library.get_item_name(selected_id)]
