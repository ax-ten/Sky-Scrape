# File: addons/mesh_adjacency_inspector/editor_adjacency_rule.gd
@tool
extends VBoxContainer
class_name EditorTiledAdjacencyRule

var rule: TiledAdjacencyRule

func setup(adj_rule: TiledAdjacencyRule):
	rule = adj_rule
	clear()
	
#region Weight input
	var weight_box := HBoxContainer.new()
	var weight_label := Label.new()
	var weight_number := SpinBox.new()
	weight_label.text = "Weight"
	weight_number.min_value = 0.0
	weight_number.step = 1.0
	
	add_child(weight_box)
	weight_box.add_child(weight_label)
	weight_box.add_child(weight_number)
#endregion
		
	for dir in rule.DIRECTIONS:
		var line := HBoxContainer.new()
		add_child(line)

#region direction label
		var label = Label.new()
		label.text = dir
		label.custom_minimum_size = Vector2(55,0)
		line.add_child(label)
#endregion

#region scrollbox
		var scrollbox := ScrollContainer.new()
		scrollbox.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scrollbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(scrollbox)
		
		var hbox := HBoxContainer.new()
		scrollbox.add_child(hbox)
#endregion

#region load rule
		for mesh_id in rule.get(dir):
			instantiate_mesh_selector(dir, hbox, mesh_id)
#endregion

#region add + button
		var plus = Button.new()
		plus.text = "+"
		plus.pressed.connect(func():
			instantiate_mesh_selector(dir,hbox,-1)
			hbox.move_child(plus, hbox.get_child_count() - 1)
			#Scrolla alla fine del hbox
			#await get_tree().process_frame  
			scrollbox.scroll_horizontal = scrollbox.get_h_scroll_bar().max_value
			rule.emit_changed()
		)
		hbox.add_child(plus)
#endregion

func clear():
#region clear children
	for n in get_children():
		remove_child(n)
		n.queue_free()
#endregion


func instantiate_mesh_selector(dir: StringName, hbox:HBoxContainer, mesh_id:int) -> MeshSelector:
	# Aggiungi un nuovo nodo a hbox, assegnando id  specificato
	var ms = MeshSelector.create_new(mesh_id) as MeshSelector
	hbox.add_child(ms)
	
	# quando vengono modificati i parametri del ms
	ms.on_parameters_changed.connect( 
		func(i):
			# Svuota la regola in quella direzione e riempila coi dati dei children attuali
			#TODO SI PUÒ SCRIVERE MEGLIO
			#print("Aggiorno la direzione ",dir, " della mesh ",mesh_id)
			var ids_in_dir := []
			#print(rule.get(dir))
			for s in hbox.get_children():
				if s is Button:	continue # ignora il pulsante +
				ids_in_dir.append(s.mesh_id)
			rule.set(dir, ids_in_dir)
			
			#rule.emit_changed()
	)
	return ms
