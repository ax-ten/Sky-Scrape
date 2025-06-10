@tool
extends GridMap
class_name WFCGridMap

const grid_from: Vector3i = Vector3i.ZERO
@export var grid_to: Vector3i = Vector3i(10, 1, 10)
@export_enum("X+",  "X-", "Y+", "Y-", "Z+", "Z-") var propagation_direction = "Z+"

@export var possibilities: Dictionary = {}
var collapsed := Set.new()
var frontier := Set.new()

#@export_tool_button("Generate all")
#var ga : Callable = func():
	#_generate_all()

#@export_tool_button("Start")
#var sg : Callable = func():
	#collapse_cell(get_starting_position(propagation_direction))
	##update_frontier()
	#
#@export_tool_button("Next")
#var nx : Callable = func():
	#step_generation()
#
#@export_tool_button("Reset")
#var clear_grid: Callable = func():
	#reset()

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


#var grid_map_editor_plugin: GridMapEditorPlugin = null
#func _enter_tree():
	#for child in get_tree().get_root().get_children():
		#if child is GridMapEditorPlugin:
			#grid_map_editor_plugin = child
			#break
#
	#if grid_map_editor_plugin:
		#print("GridMapEditorPlugin trovato!")


#func _ready():
	## Editor button compatibility
	##if not Engine.is_editor_hint():
		##return
	#reset()
	
	#var start_pos = get_starting_position(propagation_direction)
	#collapse_cell(start_pos)
	#update_frontier()

func reset():
	clear()
	collapsed.clear()
	frontier.clear()
	#update_frontier()
	possibilities.clear()
	possibilities = superpositions(grid_from, grid_to)

	
func _generate_all():
	collapse_cell(get_starting_position(propagation_direction))
	#update_frontier()
	while not frontier.is_empty():
		step_generation()


func step_generation():
	#update_frontier()
	if frontier.is_empty():
		print("Generazione completata.")
		return
	print(frontier)
	collapse_cell(least_entropy(frontier))


func collapse_cell(pos: Vector3i):
	if get_cell_item(pos) != INVALID_CELL_ITEM:
		frontier.remove(pos)
		collapsed.add(pos)
		print("cella già collassata  @" + str(pos) +" : " + str(get_cell_item(pos)) + str(mesh_library.get_item_name(get_cell_item(pos))))
		return
	var options := possibilities.get(pos, PackedInt32Array())
	if options.is_empty():
		options = [INVALID_CELL_ITEM]
	var mesh_id := weighted_random(options)
	print("pos: %s\nOpzioni: %s\nScelta: mesh_id %s - %s" % [str(pos), str(options), str(mesh_id), mesh_library.get_item_name(mesh_id)])
	if mesh_id != INVALID_CELL_ITEM:
		set_cell_item(pos, mesh_id)
	collapsed.add(pos)
	possibilities.erase(pos)
	propagate_constraints(pos)


func least_entropy(frontier : Set) -> Vector3i:
	var min_entropy := INF
	var best_pos = frontier.values()[randi_range(0, frontier.size()-1)]
	for pos in frontier:
		#print(pos)
		#print("_________________")
		#print(possibilities)
		#print("opzioni: " + str(possibilities.get(pos)))
		var options := possibilities.get(pos, PackedInt32Array())
		print("options" + str(options))
		if options.is_empty():
			continue
		var entropy = shannon_entropy(options)
		if entropy == 0.0:
			return pos
		if entropy < min_entropy:
			min_entropy = entropy
			best_pos = pos
	return best_pos


#func update_frontier():
	#frontier.clear()
	#for pos in collapsed:
		#for dir in get_directions():
			#var n = pos + dir.vector
			#if get_cell_item(n) == INVALID_CELL_ITEM:
				#frontier.add(n) 


func propagate_constraints(origin: Vector3i):
	var mesh_id = get_cell_item(origin)
	var rule: TiledAdjacencyRule = config.rules.get(mesh_id, null)
	for dir in get_directions():
		var neighbor : Vector3i= origin + dir.vector
		#print("neighbor in collapsed: %s \nneighbor in possibilities: %s" % [str(not possibilities.has(neighbor)), str(collapsed.has(neighbor))])
		if neighbor in collapsed.values() or not possibilities.has(neighbor) :
			continue
		var origin_possibilities = rule.get(dir.name) if rule else balconi
		possibilities[neighbor] = PackedInt32Array(Set.intersect(
			Set.new(possibilities[neighbor]), 
			Set.new(origin_possibilities)
			).values())
		#possibilities[neighbor] = PackedInt32Array(filtered.values())
		frontier.add(neighbor)
	print("frontier size: " + str(frontier.size()))
	print("frontier: " + str(frontier))


func weighted_random(options: PackedInt32Array) -> int:
	var total_weight := 0.0
	var weights := []
	for id in options:
		var w : float = config.rules.get(id).weight if config.rules.has(id) else 1.0
		# TODO gestire caso limite in cui non si trova il weight di una mesh
		weights.append(w)
		total_weight += w
	var r = randf() * total_weight
	for i in options.size():
		r -= weights[i]
		if r <= 0.0:
			return options[i]
	return options[-1]


func shannon_entropy(options: PackedInt32Array) -> float:
	var total := 0.0
	var sum_log := 0.0
	for id in options:
		var rule: TiledAdjacencyRule = config.rules.get(id)
		total += rule.weight if rule != null else 1.0
		var w := rule.weight if rule != null else 1.0
		sum_log += w * log(w)
	return log(total) - (sum_log / total)


## TODO custom sulla mia libreria, fatto male
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

func get_directions() -> Array:
	return [
		{name = &"X+", vector = Vector3i(1, 0, 0)},
		{name = &"X-", vector = Vector3i(-1, 0, 0)},
		{name = &"Y+", vector = Vector3i(0, 0, 1)},
		{name = &"Y-", vector = Vector3i(0, 0, -1)},
		{name = &"Z+", vector = Vector3i(0, 1, 0)},
		{name = &"Z-", vector = Vector3i(0, -1, 0)},
	]

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
