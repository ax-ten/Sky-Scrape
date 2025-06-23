extends Resource
class_name MeshGroup

@export var name : String
@export var weight : float
@export var mesh_ids : Array[int]


func _has(mesh_id:int) -> bool:
	return mesh_id in mesh_ids
