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

	return rules[id].ids_in_direction(dir_name)


func get_weighted_compatible(id: int, direction: Vector3i) -> Dictionary:
	if not rules.has(id):
		return TiledAdjacencyRule.EMPTY

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida per il WFC" % [direction])
		return TiledAdjacencyRule.EMPTY
	return rules[id].get(dir_name)


func set_rule(id: int, direction: StringName, compatible_dict: Dictionary[int, float]) -> void:
	#if not rules.has(id):
		#rules[id] = TiledAdjacencyRule.new()
	#rules[id].set(direction, compatible_dict)
	pass

func clear():
	rules.clear()

func print_rules():
	for id in rules.keys():
		print("Mesh ID:", id)
		for dir_name in ["X_pos", "X_neg", "Y_pos", "Y_neg", "Z_pos", "Z_neg"]:
			var data = rules[id].get(dir_name)
			if data.size() > 0:
				print("  ", dir_name, "→", data)

func has_rule(mesh_id: int, direction: StringName) -> bool:
	return rules.has(mesh_id) and rules[mesh_id].get(direction).size() > 0
	
func is_empty() -> bool :
	for id in rules.keys():
		for dir in TiledAdjacencyRule.DIRECTIONS:
			if rules[id].get(dir).size() > 0:
				return false
	return true
