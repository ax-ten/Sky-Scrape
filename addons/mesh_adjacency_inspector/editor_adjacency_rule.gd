# File: addons/mesh_adjacency_inspector/editor_adjacency_rule.gd
@tool
extends VBoxContainer
class_name EditorTiledAdjacencyRule

var rule: TiledAdjacencyRule

func setup(adj_rule: TiledAdjacencyRule):
	rule = adj_rule
	clear()
	if not rule:
		return
	
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

		var direction_label = Label.new()
		direction_label.text = dir
		direction_label.custom_minimum_size = Vector2(55,0)
		line.add_child(direction_label)

		#region scrollbox
		var scrollbox := ScrollContainer.new()
		scrollbox.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scrollbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(scrollbox)
		
		var hbox := HBoxContainer.new()
		scrollbox.add_child(hbox)
		#endregion

		#region load rule
		if rule == TiledAdjacencyRule.new():
			instantiate_mesh_selector(dir, hbox, -1)
		else:
			for mesh_id in rule.get(dir):
				instantiate_mesh_selector(dir, hbox, mesh_id)
		#endregion
		
		var all = Button.new()
		all.text = "all"
		all.pressed.connect( func():
			var meshids = 30 #ottenere 30 proceduralmente
			var selector : MeshSelector
			for i in range(0, meshids):
				selector = instantiate_mesh_selector(dir, hbox, i)
			update_rule(dir, hbox)
			all.queue_free()
		)
		hbox.add_child(all)

		#region add + button
		var plus = Button.new()
		plus.text = "+"
		plus.pressed.connect(func():
			instantiate_mesh_selector(dir,hbox,-1)
			hbox.move_child(plus, hbox.get_child_count() - 1)
			#Scrolla alla fine del hbox
			#await get_tree().process_frame  
			scrollbox.scroll_horizontal = scrollbox.get_h_scroll_bar().max_value
			all.queue_free()
			rule.emit_changed()
		)
		hbox.add_child(plus)
		#endregion


func clear():
	for n in get_children():
		remove_child(n)
		n.queue_free()


func instantiate_mesh_selector(dir: StringName, hbox:HBoxContainer, mesh_id:int) -> MeshSelector:
	# Aggiungi un nuovo nodo a hbox, assegnando id  specificato
	var ms = MeshSelector.create_new(mesh_id) as MeshSelector
	ms.destroy.connect(update_rule.bind(dir, hbox))
	ms.on_parameters_changed.connect(update_rule.bind(dir, hbox))

	hbox.add_child(ms)
	return ms

func update_rule(dir:StringName, hbox:HBoxContainer):
	var ids_in_dir := []
	for s in hbox.get_children():
		if s is not Button:  # ignora il pulsante +
			ids_in_dir.append(s.mesh_id)
	rule.set(dir, ids_in_dir)
