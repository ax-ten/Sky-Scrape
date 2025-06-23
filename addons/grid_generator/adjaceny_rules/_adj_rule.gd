extends Resource
class_name _AdjacencyRule

const DIRECTIONS = [&"X+",  &"X-", &"Y+", &"Y-", &"Z+", &"Z-"]


func _init() -> void: 
	pass
	
func _append(direction: StringName, to_append): 
	pass

func _remove(direction: StringName, to_remove) -> bool:
	return true

func clear(direction: StringName): 
	pass
	
func _set(direction: StringName, values) -> bool:
	return false
	
func _get(direction: StringName) -> Variant: 
	return null
	
func _has(direction: StringName, mesh_id) -> bool: 
	return false
	
func save() -> bool: 
	return false
	
func  is_empty() -> bool: 
	return true
	
func _to_string() -> String: 
	return ""
	
func duplicate(subresources: bool = false) -> Resource: 
	return null
