@tool
extends Resource
class_name _MeshAdjacencyConfiguration

func is_empty() -> bool : return true
func get_compatible(v: Variant, dir: Vector3i) -> Array : return []

const VECTOR_TO_DIR = {
	Vector3i(1, 0, 0): &"X+",
	Vector3i(-1, 0, 0): &"X-",
	Vector3i(0, 1, 0): &"Z-",
	Vector3i(0, -1, 0): &"Z+",
	Vector3i(0, 0, 1): &"Y+",
	Vector3i(0, 0, -1): &"Y-"
}
