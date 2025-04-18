@tool
extends Panel
class_name MeshWeightSelector

var mesh_id : int
var weight : float
signal on_parameters_changed(mesh_id, weight)
@export var preview : SpinTextureBox
@export var w_line : LineEdit

func _on_weight_submitted(new_text: String) -> void:
	_set("weight", float(new_text))
#TODO funzione per assicurarsi che weight sia un float
#TODO vedi perché weight è negativo

func _on_index_changed(index: int) -> void:
	_set("mesh_id", index)
	#preview.index_changed.emit()

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"mesh_id": 
			mesh_id = value
			preview.set_preview(value)
		"weight": 
			weight = value
			w_line.text = str(value)
	on_parameters_changed.emit(mesh_id, weight)
	return true


const scene : PackedScene = preload("res://addons/mesh_adjacency_inspector/mesh_weight_selector.tscn")
static func create_new(id:int, w:float) -> MeshWeightSelector:
	var instance : MeshWeightSelector = scene.instantiate() as MeshWeightSelector
	instance._set("mesh_id",id)
	instance._set("weight",  w)
	instance.on_parameters_changed.emit(id, w)
	return instance


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				queue_free()
				get_viewport().set_input_as_handled()
