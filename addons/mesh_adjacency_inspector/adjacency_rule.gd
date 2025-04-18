@tool
extends Resource
class_name TiledAdjacencyRule

# Dizionario [id_mesh, weight]
# dove weight è la probabilità relativa che un blocco venga piazzato
@export var X_pos : Dictionary
@export var X_neg : Dictionary
@export var Y_pos : Dictionary
@export var Y_neg : Dictionary
@export var Z_pos : Dictionary
@export var Z_neg : Dictionary
const DIRECTIONS = ["X+", "X-", "Y+", "Y-", "Z+", "Z-"]
const EMPTY = {-1: 1.0}
#const directions = ["X_pos", "X_neg", "Y_pos", "Y_neg", "Z_pos", "Z_neg"]


func _init() -> void:
	for dir in DIRECTIONS:
		_set(dir, EMPTY)
	changed.connect(save)


func update(property: StringName, mesh_id:int, weight:float):
	match property:
		DIRECTIONS[0]: X_pos[mesh_id]=weight
		DIRECTIONS[1]: X_neg[mesh_id]=weight
		DIRECTIONS[2]: Y_pos[mesh_id]=weight
		DIRECTIONS[3]: Y_neg[mesh_id]=weight
		DIRECTIONS[4]: Z_pos[mesh_id]=weight
		DIRECTIONS[5]: Z_neg[mesh_id]=weight
	save()
	return null

func ids_in_direction(direction:StringName):
	match direction:
		DIRECTIONS[0]: return X_pos.keys()
		DIRECTIONS[1]: return X_neg.keys()
		DIRECTIONS[2]: return Y_pos.keys()
		DIRECTIONS[3]: return Y_neg.keys()
		DIRECTIONS[4]: return Z_pos.keys()
		DIRECTIONS[5]: return Z_neg.keys()
	return null

func _get(property: StringName) -> Dictionary:
	match property:
		DIRECTIONS[0]: return X_pos
		DIRECTIONS[1]: return X_neg
		DIRECTIONS[2]: return Y_pos
		DIRECTIONS[3]: return Y_neg
		DIRECTIONS[4]: return Z_pos
		DIRECTIONS[5]: return Z_neg
	return {}


func _set(property: StringName, value):
	if value is Dictionary:
		value as Dictionary[int,float]
	match property:
		DIRECTIONS[0]: X_pos = value
		DIRECTIONS[1]: X_neg = value
		DIRECTIONS[2]: Y_pos = value
		DIRECTIONS[3]: Y_neg = value
		DIRECTIONS[4]: Z_pos = value
		DIRECTIONS[5]: Z_neg = value
	save()
	return true


func save() -> void:
	if resource_path:
		ResourceSaver.save(self, resource_path)


func _to_string() -> String:
	var strin = ''
	for dir in DIRECTIONS:
		if _get(dir) != EMPTY:
			strin += dir +":"+ str(_get(dir))+ "\n"
	return strin
