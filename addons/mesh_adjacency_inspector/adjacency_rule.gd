@tool # adjacency_rule.gd
extends Resource
class_name TiledAdjacencyRule

# Dizionario [id_mesh, weight]
# dove weight è la probabilità relativa che il blocco associato a questa regola sia piazzato
var weight : float = 1.0
const AIR : PackedInt32Array = [-1]
const EMPTY : PackedInt32Array = []
const DIRECTIONS = [&"X+",  &"X-", &"Y+", &"Y-", &"Z+", &"Z-"]
var ADJACENCIES : Dictionary[StringName, PackedInt32Array]
						# 	 Direction,  Mesh_ids


func _init() -> void: 
	connect(&"changed", save)
	for dir in DIRECTIONS:
		ADJACENCIES[dir] = EMPTY


func _append(direction: StringName, mesh_id:int):
	ADJACENCIES[direction].append(mesh_id)
	emit_changed()


func _remove(direction: StringName, id_to_remove:int) -> bool:
	if id_to_remove not in ADJACENCIES[direction]:
		return false
	
	var filtered : PackedInt32Array = []
	for v in ADJACENCIES[direction]:
		if v != id_to_remove:
			filtered.append(v)
	_set(direction, filtered)
	return true
	

func clear(direction: StringName) -> bool:
	if direction not in DIRECTIONS:
		return false
	ADJACENCIES[direction] = EMPTY
	return true

func _set(direction: StringName, values: Variant) -> bool:
	if values is Array:
		ADJACENCIES[direction]= PackedInt32Array(values)
	elif values is PackedInt32Array:
		ADJACENCIES[direction]= values
	else:
		return false
		
	emit_changed()
	return true
	

func _get(direction: StringName):
	if not ADJACENCIES.has(direction):
		return null
	return ADJACENCIES[direction]
	

func _has(direction: StringName, mesh_id) -> bool:
	return mesh_id in _get(direction)


func save() -> bool:
	if not resource_path:
		return false
	ResourceSaver.save(self, resource_path)
	#print('[DEBUG] ', "Risorsa salvata")
	return true


func  is_empty() -> bool:
	for dir in DIRECTIONS:
		if ADJACENCIES[dir] != EMPTY:
			return true
	return false


func _to_string() -> String:
	var strin = ''
	for dir in DIRECTIONS:
		if _get(dir) != EMPTY or _get(dir) != AIR:
			strin += dir +":"+ str(_get(dir))+ "\n"
	return strin
