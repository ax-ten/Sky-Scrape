extends _RuleInspector
class_name SimpleRuleInspector

var rule: TiledAdjacencyRule
var meshlibrary: MeshLibrary = preload("res://Nodes/Palazzo/PalazzoMeshLibrary.tres")
var textures: Array[Texture2D]
#var hboxes: Dictionary[StringName, MeshListSelector]

func _init() -> void:
	visible = false
	add_child(_weight_box())
	for mesh_id in meshlibrary.get_item_list():
		textures.append(meshlibrary.get_item_preview(mesh_id))


func setup(adj_rule: TiledAdjacencyRule):
	rule = adj_rule
	clear()
	if not rule:
		return
	_init()
	visible = true
	for dir in rule.DIRECTIONS:
		var hbox := HBoxContainer.new()
		
		var direction_label := Label.new()
		direction_label.text = dir
		direction_label.custom_minimum_size = Vector2(50,0)
		
		var mesh_selector := MeshListSelector.new()
		mesh_selector.setup(rule._get(dir), textures)
		mesh_selector.updated.connect(func():
			rule.emit_changed()
			rule._set(dir, mesh_selector.mesh_ids)
			)
		#hboxes[dir] = mesh_selector
		
		add_child(hbox)
		hbox.add_child(direction_label)
		hbox.add_child(mesh_selector)

func clear():
	textures.clear()
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _weight_box() -> HBoxContainer:
	var weight_box := HBoxContainer.new()
	var weight_label := Label.new()
	var weight_number := SpinBox.new()
	weight_label.text = "Weight"
	weight_number.min_value = 0.0
	weight_number.step = 0.5
	weight_box.add_child(weight_label)
	weight_box.add_child(weight_number)
	return weight_box
