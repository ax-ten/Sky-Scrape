@tool
extends Resource
class_name MeshAdjacencyConfiguration

@export var rules: Dictionary[int, TiledAdjacencyRule] = {}
const VECTOR_TO_DIR = {
	Vector3i(1, 0, 0): &"X+",
	Vector3i(-1, 0, 0): &"X-",
	Vector3i(0, 1, 0): &"Z-",
	Vector3i(0, -1, 0): &"Z+",
	Vector3i(0, 0, 1): &"Y+",
	Vector3i(0, 0, -1): &"Y-"
}

func get_compatible(id: int, direction: Vector3i) -> Array:
	if rules.get(id, null) == null:
		return []

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida per il WFC" % [direction])
		return []

	return rules[id].get(dir_name)


func get_weighted_compatible(id: int, direction: Vector3i) -> PackedInt32Array:
	if not rules.has(id):
		return TiledAdjacencyRule.EMPTY

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida per il WFC" % [direction])
		return TiledAdjacencyRule.EMPTY
	return rules[id].get(dir_name)

	
func is_empty() -> bool :
	for rule in rules.values():
		if rule and not rule.is_empty():
			return false
	return true
