extends Panel
class_name MeshWeightSelector

const scene : PackedScene = preload("res://addons/mesh_adjacency_inspector/mesh_weight_selector.tscn")
static func create_new():
	return scene.instantiate()

var mesh_id : int
var weight : float
signal on_parameters_changed(new_mesh_id:int, new_weight:float)

func _on_weight_submitted(new_text: String) -> void:
	weight = float(new_text)
	on_parameters_changed.emit(mesh_id, weight)

func _on_index_changed(index: int) -> void:
	mesh_id = index
	on_parameters_changed.emit(mesh_id, weight)
