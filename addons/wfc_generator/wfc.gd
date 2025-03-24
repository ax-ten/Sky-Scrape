@tool
extends GridMap
class_name WFCGridMap

# Direzioni standard in 3D (non etichettate)
const DIRECTIONS = [
	Vector3(1, 0, 0),   # +X
	Vector3(-1, 0, 0),  # -X
	Vector3(0, 1, 0),   # +Y
	Vector3(0, -1, 0),  # -Y
	Vector3(0, 0, 1),   # +Z
	Vector3(0, 0, -1)   # -Z
]
const DIRECTION_NAMES = ["+x", "-x", "+y", "-y", "+z", "-z"]
#@export_tool_button("Genera")
#var g : Callable = func():
	#generate(Vector3.ZERO,Vector3(-3,-1,-3))
#
#@export_tool_button("Clear")
#var c : Callable = func():
	#clear()

@export var adjacency_config: MeshAdjacencyConfiguration

# Mappa delle possibilità per ogni cella
var possibilities := {}

func is_empty() -> bool:
	return adjacency_config.is_empty()


func _get_configuration_warnings():
	if !mesh_library:
		return ["Associa una MeshLibrary a questo nodo"]
	elif adjacency_config.is_empty():
		return ['Configura i collegamenti delle tessere']
	else:
		return []


func generate(start: Vector3, end: Vector3) -> void:
	var from = Vector3(min(start.x, end.x), min(start.y, end.y), min(start.z, end.z))
	var to = Vector3(max(start.x, end.x), max(start.y, end.y), max(start.z, end.z))

	print("Creo la matrice di possibilità")
	possibilities.clear()
	for x in range(from.x, to.x + 1):
		for y in range(from.y, to.y + 1):
			for z in range(from.z, to.z + 1):
				var pos = Vector3i(x, y, z)
				if get_cell_item(pos) != -1:
					continue
				possibilities[pos] = mesh_library.get_item_list().duplicate()

	print("Propago")
	_propagate()

	for pos in possibilities:
		var options = possibilities[pos]
		if options.size() == 0:
			continue
		var chosen = options[randi() % options.size()]
		set_cell_item(pos, chosen)
	print("impostati tutti i cell items")

func _propagate() -> void:
	if adjacency_config == null:
		return

	var changed = true
	while changed:
		changed = false
		for pos in possibilities.keys():
			for i in range(DIRECTIONS.size()):
				var dir = DIRECTIONS[i]
				var neighbor = pos + dir
				if not possibilities.has(neighbor):
					continue
				var possible_here = possibilities[pos]
				var possible_there = possibilities[neighbor]
				var filtered := []

				for id in possible_there:
					var compatible := false
					for my_id in possible_here:
						if id in adjacency_config.get_compatible(my_id, DIRECTION_NAMES[i]):
							compatible = true
							break
					if compatible:
						filtered.append(id)

				if filtered.size() < possible_there.size():
					possibilities[neighbor] = filtered
					changed = true
