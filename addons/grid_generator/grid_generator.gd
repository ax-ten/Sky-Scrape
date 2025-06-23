@tool
extends GridMap
class_name GridGenerator


var generation: GenerationAlgorithm = WFCAlgorithm.new()
signal do_reset

var possibilities: Dictionary = {}
var collapsed := Set.new() # set of Vector3i
var frontier := Set.new() # set of Vector3i

#@export_tool_button("Generate all")
#var ga : Callable = func():
	#_generate_all()

#@export var visualizer : Visualizer
@export_tool_button("    Generate all    ", "Play")
var sg : Callable = func():
	reset()
	possibilities = wave(_from, _to)
	generation.step(self)
	generation.populate(self)
	#collapse_cell(get_starting_position(propagation_direction))
	
@export_tool_button("     Next step       ", "MoveRight")
var nx : Callable = func():
	generation.step(self)
	#visualizer.visualize(possibilities)


@export_tool_button("Reset + inizialize", "Reload")
var clear_grid: Callable = func():
	reset()
	print("from: ", _from, "    to: ", _to)
	possibilities = wave(_from, _to)
	generation.reset_state()

@export_enum("Wave Function Collapse", "Model Synthesis") 
var generation_algorithm := 0:
	set(value):
		generation_algorithm = value
		generation = [WFCAlgorithm, MSAlgorithm][generation_algorithm].new()
		notify_property_list_changed()

@export_enum("X+",  "X-", "Y+", "Y-", "Z+", "Z-") var propagation_direction = "Z+"



@export_category("Generation Region")
@export var _from :=  Vector3i(0, 0, 0)
@export var _to  :=  Vector3i(5, 2, 5)




@export_category("Adjacency configurator")
@export var config: _MeshAdjacencyConfiguration


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
	if property.name == "direction_matrix" and config is not SimpleAdjacencyConfiguration:
		property.usage = PROPERTY_USAGE_NO_EDITOR

#func _init() -> void:
#var balconi = PackedInt32Array([0,1,2,3,4,5,6,15,16,17,18,22,23,24,-1,25,26,27,28,29])

#region DebugSubscriber
var debug_info : Dictionary [String, Callable] = {
	"Frontier size" : frontier.size,
	"generation zone" : func(): return [_from, _to],
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
	generation.reset_state()
	collapsed.clear()


func validity() -> bool:
	for pos in collapsed:
		for dir in direction_matrix:
			var neighbor_item = get_cell_item(pos + dir.vector)
			var pos_item = get_cell_item(pos)
			if neighbor_item not in config.rules[pos_item].get(dir):
				return false
	return true
	

func propagate_constraints(origin: Vector3i):
	var mesh_id = get_cell_item(origin)
	var rule: TiledAdjacencyRule = config.rules.get(mesh_id)
	if mesh_id == -1:
		rule = config.air_rule()
	for dir in direction_matrix:
		var neighbor : Vector3i= origin + dir.vector
		#print("neighbor in collapsed: %s \nneighbor in possibilities: %s" % [str(not possibilities.has(neighbor)), str(collapsed.has(neighbor))])
		if not possibilities.has(neighbor) :
			continue
		var origin_possibilities = rule.get(dir.name)
		possibilities[neighbor] = PackedInt32Array(Set.intersect(
			Set.new(possibilities[neighbor]), 
			Set.new(origin_possibilities)
			).values())
		frontier.add(neighbor)


func get_weights(options:PackedInt32Array) -> Array[float]:
	#if options.is_empty():
		#return config.rules.values()
	var weights : Array[float]
	for id in options:
		weights.append(get_weight(id))
	return weights


func get_weight(id) -> float:
	const DEFAULT_WEIGHT : float = 1.0
	if config.rules.has(id):
		return config.rules.get(id).weight 
	return DEFAULT_WEIGHT


## TODO custom sulla mia libreria, è fatto male
func wave(from: Vector3, to: Vector3) -> Dictionary:
	#var mesh_list := mesh_library.get_item_list().duplicate()
	#mesh_list.append(INVALID_CELL_ITEM) # Anche una mesh vuota è valida
	var grid : Dictionary = {}
	for x in range(from.x, to.x):
		for z in range(from.z, to.z):
			for y in range(from.y, to.y):
				grid[Vector3i(x, y, z)] = PackedInt32Array(mesh_library.get_item_list())
	#grid[get_starting_position(propagation_direction)] = PackedInt32Array([7,8,9,10,11,12,13,14,19,20,21])
	grid[Vector3i(0,0,0)] = PackedInt32Array([0,1,2,3,4,5,6,15,16,17,18,22,23,24,25,26,27,28,29])
	return grid




func get_starting_position(dir: String) -> Vector3i:
	var medians = [(_from.x + _to.x) / 2, (_from.y + _to.y) / 2, (_from.z + _to.z) / 2]
	#match dir:
		#"X+": return Vector3i(_to.x, _to.y, medians[2])
		#"X-": return Vector3i(_from.x, _from.y, medians[2])
		#"Z+": return Vector3i(_from.x, medians[1], _to.z)
		#"Z-": return Vector3i(_from.x, medians[1], _from.z)
		#"Y+": return Vector3i(medians[0], _to.y, _from.z)
		#"Y-": return Vector3i(medians[0], _from.y, _from.z)
		#_: return Vector3i(medians[0], _from.y, medians[2])
	#return Vector3i(medians[0], medians[1], medians[2])
	return Vector3i(0,1,0)

func _get_configuration_warnings():
	if !mesh_library:
		return ["Associa una MeshLibrary a questo nodo"]
	elif !config:
		return ["Associa una MeshConfiguration a questo nodo"]
	#elif config.is_empty():
		#return ['Configura i collegamenti delle tessere']
	else:
		return []
