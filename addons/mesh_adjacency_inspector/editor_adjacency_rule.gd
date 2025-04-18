# File: addons/mesh_adjacency_inspector/editor_adjacency_rule.gd
@tool
extends VBoxContainer
class_name EditorTiledAdjacencyRule

var rule: TiledAdjacencyRule

func setup(adj_rule: TiledAdjacencyRule):
	rule = adj_rule
	
	# clear children
	for n in get_children():
		remove_child(n)
		n.queue_free()
		
	for dir in rule.DIRECTIONS:
		var line := HBoxContainer.new()
		add_child(line)
		
		var label = Label.new()
		label.text = dir
		label.custom_minimum_size = Vector2(50,0)
		line.add_child(label)
		
		var scrollbox := ScrollContainer.new()
		scrollbox.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scrollbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(scrollbox)
		
		var hbox := HBoxContainer.new()
		scrollbox.add_child(hbox)

		# Carica da rule
		if rule.get(dir):
			#print("DEBUG", str(rule.get(dir)) )
			var direction_dict: Dictionary = rule.get(dir) 
			for mesh_id in direction_dict:
				var weight = direction_dict[mesh_id]
				instantiate_mesh_selector(dir, hbox, mesh_id, weight)

		# Bottone +
		var plus = Button.new()
		plus.text = "+"
		plus.pressed.connect(func():
			instantiate_mesh_selector(dir,hbox,-1,1)
			hbox.move_child(plus, hbox.get_child_count() - 1)
			#Scrolla alla fine del hbox
			await get_tree().process_frame  
			scrollbox.scroll_horizontal = 6000#scrollbox.get_h_scroll_bar().max_value
		)
		hbox.add_child(plus)


func instantiate_mesh_selector(dir: StringName, hbox:HBoxContainer, id:int, weight:float) -> MeshWeightSelector:
	# Aggiungi un nuovo nodo a hbox, assegnando id e w specificati
	var mws = MeshWeightSelector.create_new(id, weight) as MeshWeightSelector
	hbox.add_child(mws)
	
	# quando vengono modificati i parametri del MWS
	mws.on_parameters_changed.connect( func(i,w):
		# Svuota la regola in quella direzione e riempila coi dati dei children attuali
		rule.set(dir, {})
		for s in hbox.get_children():
			if s is Button:
				continue
			
			#print("[DEBUG] dir: ", dir ," id: ",s.mesh_id, "   w:",  -s.weight)
			rule.update(dir, s.mesh_id, s.weight)
		rule.emit_changed()
	)
	return mws
