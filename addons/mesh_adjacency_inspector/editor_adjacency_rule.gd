# File: addons/mesh_adjacency_inspector/editor_adjacency_rule.gd
@tool
extends VBoxContainer
class_name EditorAdjacencyRule

var rule: AdjacencyRule
const DIRECTION_NAMES := ["X_pos", "X_neg", "Y_pos", "Y_neg", "Z_pos", "Z_neg"]


func setup(adj_rule: AdjacencyRule):
	rule = adj_rule
	#clear()

	for dir in DIRECTION_NAMES:
		var hbox := HBoxContainer.new()
		add_child(hbox)
		
		var label = Label.new()
		label.text = dir
		hbox.add_child(label)

		# Carica da rule
		var dict: Dictionary = rule.get(dir)
		for id in dict.keys():
			var selector = MeshWeightSelector.create_new()
			selector.get_node("Preview").index = id
			selector.get_node("Weight").value = dict[id]
			hbox.add_child(selector)

		# Vuota iniziale
		hbox.add_child(MeshWeightSelector.create_new())

		# Bottone +
		var plus = Button.new()
		plus.text = "+"
		plus.pressed.connect(func():
			hbox.add_child(MeshWeightSelector.create_new())
			hbox.move_child(plus, hbox.get_child_count() - 1)
		)
		hbox.add_child(plus)
