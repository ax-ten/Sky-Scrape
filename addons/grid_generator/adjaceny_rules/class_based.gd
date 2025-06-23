extends _AdjacencyRule
class_name ClassAdjacencyRule


var ADJACENCIES : Dictionary[StringName, Array]
	# Stringname: direzione
	# Array[MeshGroup] : tutte le classi assegnabili in quella direzione

func _init() -> void: 
	pass
	
func _append(direction: StringName, group: MeshGroup): 
	ADJACENCIES[direction].append(group)

func _remove(direction: StringName, to_remove:MeshGroup) -> bool:
	for i in ADJACENCIES[direction].size():
		if ADJACENCIES[direction][i].name == to_remove.name:
			ADJACENCIES[direction].remove_at(i)
			return true
	return false

func clear(direction: StringName) -> bool: 
	ADJACENCIES[direction] = []
	return true
	
func _set(direction: StringName, values: Variant) -> bool:
	ADJACENCIES[direction] = values
	return true
	
func _get(direction: StringName) -> Array[MeshGroup]: 
	if not ADJACENCIES.has(direction):
		return []
	return ADJACENCIES[direction]
	
	
func _has(direction: StringName, mesh_id) -> bool: 
	for group in ADJACENCIES[direction]:
		if mesh_id in group:
			return true
	return false
	
func save() -> bool: 
	if not resource_path:
		return false
	ResourceSaver.save(self, resource_path)
	return true
	
func  is_empty() -> bool: 
	for dir in DIRECTIONS:
		if _get(dir) != []:
			return false
	return true
	
func _to_string() -> String: 
	var strin = ''
	for dir in DIRECTIONS:
		strin += dir + '\n'
		for group in ADJACENCIES[dir]:
			strin += group.to_string() +  '\n'
		strin+= '\n'
	return strin
	
func duplicate(subresources: bool = false) -> Resource: 
	var d := ClassAdjacencyRule.new()
	d.ADJACENCIES = ADJACENCIES.duplicate()
	return d
