@tool
extends GridMap
class_name GridGenerator


var generation: GenerationAlgorithm = WFCAlgorithm.new()


var possibilities: Dictionary = {}
#var collapsed := Set.new()
var frontier := Set.new()

#@export_tool_button("Generate all")
#var ga : Callable = func():
	#_generate_all()

@export_tool_button("    Generate all    ", "Play")
var sg : Callable = func():
	generation.do(self)
	#collapse_cell(get_starting_position(propagation_direction))
	
@export_tool_button("     Next step       ", "MoveRight")
var nx : Callable = func():
	generation.step(self)

@export_tool_button("Reset + inizialize", "Reload")
var clear_grid: Callable = func():
	reset()

@export_enum("Wave Function Collapse", "Model Synthesis") 
var generation_algorithm := 0:
	set(value):
		generation_algorithm = value
		generation = [WFCAlgorithm, MSAlgorithm][generation_algorithm].new()
		notify_property_list_changed()

@export_enum("X+",  "X-", "Y+", "Y-", "Z+", "Z-") var propagation_direction = "Z+"


var grid_from: Vector3i
var grid_to: Vector3i
@export_category("Generation Region")
@export var gridsize: Array[Direction3D] = [
	Direction3D.create(&"from", Vector3i(0, 0, 0)),
	Direction3D.create(&"to", Vector3i(10, 0, 0)),
] : 
	set(value):
		var from = value[0].vector
		var to = value[1].vector
		# Se to non è maggiore o uguale su ogni asse, annulla
		if to.x < from.x or to.y < from.y or to.z < from.z:
			push_warning("grid_to deve essere >= grid_from su tutti gli assi.")
			return
		gridsize = value
		grid_from = from
		grid_to = to
		notify_property_list_changed()


@export_category("Direction Transformation Matrix")
@export var direction_matrix: Array[Direction3D] = [
	Direction3D.create(&"X+", Vector3i(1, 0, 0)),
	Direction3D.create(&"X-", Vector3i(-1, 0, 0)),
	Direction3D.create(&"Y+", Vector3i(0, 0, 1)),
	Direction3D.create(&"Y-", Vector3i(0, 0, -1)),
	Direction3D.create(&"Z+", Vector3i(0, 1, 0)),
	Direction3D.create(&"Z-", Vector3i(0, -1, 0)),
]

func _validate_property(property: Dictionary):
	if property.name in ["direction_matrix"] and config is not SimpleTiledAdjacency:
		property.usage = PROPERTY_USAGE_NO_EDITOR


@export_category("Adjacency configurator")
@export var config: MeshAdjacencyConfiguration
var balconi = PackedInt32Array([0,1,2,3,4,5,6,15,16,17,18,22,23,24,-1,25,26,27,28,29])

#region DebugSubscriber
var debug_info : Dictionary [String, Callable] = {
	"Frontier size" : frontier.size,
	"generation zone" : func(): return [grid_from, grid_to],
	"propagation direction" : func(): return propagation_direction,
	#"Editorinterface children" : EditorInterface.get_editor_main_screen().get_children(true),
	#"Selection" : pos,
	#"options" : possibilities.get(pos, []),
	#"entroyp" : shannon_entropy(possibilities.get(pos, [])),
}
#endregion


func reset():
	clear()
	frontier.clear()
	possibilities.clear()
	possibilities = superpositions(grid_from, grid_to)


func propagate_constraints(origin: Vector3i):
	var mesh_id = get_cell_item(origin)
	var rule: TiledAdjacencyRule = config.rules.get(mesh_id, null)
	for dir in direction_matrix:
		var neighbor : Vector3i= origin + dir.vector
		#print("neighbor in collapsed: %s \nneighbor in possibilities: %s" % [str(not possibilities.has(neighbor)), str(collapsed.has(neighbor))])
		if not possibilities.has(neighbor) :
			continue
		var origin_possibilities = rule.get(dir.name) if rule else balconi
		possibilities[neighbor] = PackedInt32Array(Set.intersect(
			Set.new(possibilities[neighbor]), 
			Set.new(origin_possibilities)
			).values())
		frontier.add(neighbor)



func get_weights(options:PackedInt32Array=[]) -> Array[float]:
	if options.is_empty():
		return config.rules.values()
	var weights :PackedInt32Array = []
	for id in options:
		weights.append(get_weight(id))
	return weights


func get_weight(id) -> float:
	const DEFAULT_WEIGHT : float = 1.0
	if config.rules.has(id):
		return config.rules.get(id).weight 
	return DEFAULT_WEIGHT


## TODO custom sulla mia libreria, è fatto male
func superpositions(from: Vector3, to: Vector3) -> Dictionary:
	#var mesh_list := mesh_library.get_item_list().duplicate()
	#mesh_list.append(INVALID_CELL_ITEM) # Anche una mesh vuota è valida
	var grid : Dictionary = {}
	for x in range(from.x, to.x + 1):
		for z in range(from.z, to.z + 1):
			grid[Vector3i(x, 1, z)] = PackedInt32Array([7,8,9,10,11,12,13,14, 19,20,21])
			grid[Vector3i(x, 0, z)] = balconi
	grid[get_starting_position(propagation_direction)] = PackedInt32Array([7,8,9,10,11,12,13,14, 19,20,21])
	return grid




func get_starting_position(dir: String) -> Vector3i:
	var medians = [(grid_from.x + grid_to.x) / 2, (grid_from.y + grid_to.y) / 2, (grid_from.z + grid_to.z) / 2]
	match dir:
		"X+": return Vector3i(grid_to.x, grid_to.y, medians[2])
		"X-": return Vector3i(grid_from.x, grid_from.y, medians[2])
		"Z+": return Vector3i(grid_from.x, medians[1], grid_to.z)
		"Z-": return Vector3i(grid_from.x, medians[1], grid_from.z)
		"Y+": return Vector3i(medians[0], grid_to.y, grid_from.z)
		"Y-": return Vector3i(medians[0], grid_from.y, grid_from.z)
		_: return Vector3i(medians[0], grid_from.y, medians[2])

func _get_configuration_warnings():
	if !mesh_library:
		return ["Associa una MeshLibrary a questo nodo"]
	elif !config:
		return ["Associa una MeshConfiguration a questo nodo"]
	elif config.is_empty():
		return ['Configura i collegamenti delle tessere']
	else:
		return []
