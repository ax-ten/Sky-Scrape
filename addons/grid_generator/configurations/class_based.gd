@tool
extends _MeshAdjacencyConfiguration
class_name ClassAdjacencyConfiguration



@export var rules: Dictionary[MeshGroup, TiledAdjacencyRule] = {}


func get_compatible(id: Variant, direction: Vector3i) -> Array:
	if rules.get(id, null) == null:
		return []

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida" % [direction])
		return []

	return rules[id].get(dir_name)


func get_weighted_compatible(id: Variant, direction: Vector3i) -> PackedInt32Array:
	if not rules.has(id):
		return TiledAdjacencyRule.EMPTY

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida per il WFC" % [direction])
		return TiledAdjacencyRule.EMPTY
	return rules[id].get(dir_name)
#
