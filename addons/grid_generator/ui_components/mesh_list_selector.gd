extends ScrollContainer
class_name MeshListSelector

signal updated
var mesh_ids: PackedInt32Array
var textures: Array[Texture2D]
var hbox := HBoxContainer.new()


func _init():
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.child_entered_tree.connect(update_mesh_ids)
	add_child(hbox)


func setup(_mesh_ids, _textures: Array[Texture2D]):
	textures = _textures
	hbox.child_entered_tree.disconnect(update_mesh_ids)

	for mesh_id in _mesh_ids:
		hbox.add_child(_new_mesh_selector(mesh_id))

	if hbox.get_child_count() == 0:
		hbox.add_child(_new_mesh_selector(-1))
	hbox.add_child(_all_button(hbox))

	hbox.add_child(_plus_button(hbox))
	hbox.child_entered_tree.connect(update_mesh_ids)
	mesh_ids = _mesh_ids


func update_mesh_ids(n):
	await get_tree().process_frame
	await get_tree().process_frame
	mesh_ids.clear()
	for node in hbox.get_children():
		if not node is TextureSpinbox:
			continue
		mesh_ids.append(node.shown)
	updated.emit()
	#print("Meshids: ", mesh_ids)


func _new_mesh_selector(mesh_id: int) -> TextureSpinbox:
	var ms := TextureSpinbox.create_new(mesh_id, textures)
	ms.destroy.connect(
		func():
			#print("destroyed")
			update_mesh_ids(ms)
			)
	ms.on_parameters_changed.connect( 
		func():
			#print("parameters changed")
			update_mesh_ids(ms)
			)
	return ms


func _all_button(hbox: HBoxContainer) -> Button:
	var all = Button.new()
	all.text = "all"
	all.pressed.connect(func():
		for child in hbox.get_children():
			hbox.remove_child(child)
			child.queue_free()
		for i in textures.size():
			hbox.add_child(_new_mesh_selector(i))
		#hbox.add_child(_plus_button(hbox))
		updated.emit()
		all.queue_free()
	)
	return all

func _plus_button(hbox: HBoxContainer) -> Button:
	var plus := Button.new()
	plus.text = "+"
	plus.pressed.connect(func():
		hbox.add_child(_new_mesh_selector(-1))
		hbox.move_child(plus, -1)
		var scrollbox: ScrollContainer = hbox.get_parent()
		scrollbox.scroll_horizontal = scrollbox.get_h_scroll_bar().max_value
		#updated.emit()
	)
	return plus
