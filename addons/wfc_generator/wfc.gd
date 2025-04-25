@tool
extends GridMap
class_name WFCGridMap

const grid_from: Vector3i = Vector3i.ZERO
@export var grid_to: Vector3i = Vector3i(10, 2, 10)
@export_enum("X+",  "X-", "Y+", "Y-", "Z+", "Z-") var propagation_direction = "Z+"

var possibilities: Dictionary = {}
var collapsed: Dictionary = {}
var frontier := Set.new()

@export_category("Debug Tools")
var debug : Label
@export_tool_button("Generate all")
var ga : Callable = func():
			_generate_all()

@export_tool_button("Propagate once")
var sg : Callable = func():
			step_generation()
			
@export_tool_button("Clear all")
var clear_grid: Callable = func():
	clear()
	possibilities.clear()
	collapsed.clear()
	frontier.clear()
	debug = null


@export_category("Adjacency configurator")
@export var config: MeshAdjacencyConfiguration

func _process(delta):
	if Engine.is_editor_hint():
		_update_debug_label()

var grid_map_editor_plugin: GridMapEditorPlugin = null
func _enter_tree():
	for child in get_tree().get_root().get_children():
		if child is GridMapEditorPlugin:
			grid_map_editor_plugin = child
			break

	if grid_map_editor_plugin:
		print("GridMapEditorPlugin trovato!")

func _update_debug_label():
	if debug == null:
		print("debug assegnato a viewport")
		debug = Label.new()
		EditorInterface.get_editor_viewport_3d().add_child(debug)
		
	#if not debug.get_parent().is_class("Viewport"):
	#get_viewport().add_child(debug)
		#EditorInterface.get_editor_viewport_2d().add_child(debug)
	
	var info := []
	info.append("Frontier size: %d" % frontier.size())
	#var selection := EditorInterface.
	#if selection and selection.size() > 0:
		#var pos = selection[0]
		#info.append("Selected: %s" % pos)
		#var opts = possibilities.get(pos, [])
		#info.append("Options: %s" % str(opts))
		#info.append("Entropy: %.2f" % shannon_entropy(opts))
	#else:
		#info.append("Selected: none")
	debug.text = "\n".join(info)


func _ready():
	# Editor button compatibility
	if Engine.is_editor_hint():
		return
	possibilities = superpositions(grid_from, grid_to)
	var start_pos = get_starting_position(propagation_direction)
	collapse_cell(start_pos)
	update_frontier()

func get_starting_position(dir: String) -> Vector3i:
	match dir:
		"X+": return Vector3i(grid_to.x, grid_from.y, (grid_from.z + grid_to.z) / 2)
		"X-": return Vector3i(grid_from.x, grid_from.y, (grid_from.z + grid_to.z) / 2)
		"Z+": return Vector3i((grid_from.x + grid_to.x) / 2, grid_from.y, grid_to.z)
		"Z-": return Vector3i((grid_from.x + grid_to.x) / 2, grid_from.y, grid_from.z)
		"Y+": return Vector3i((grid_from.x + grid_to.x) / 2, grid_to.y, (grid_from.z + grid_to.z) / 2)
		"Y-": return Vector3i((grid_from.x + grid_to.x) / 2, grid_from.y, (grid_from.z + grid_to.z) / 2)
		_: return Vector3i((grid_from.x + grid_to.x) / 2, grid_from.y, (grid_from.z + grid_to.z) / 2)

func superpositions(from: Vector3, to: Vector3) -> Dictionary:
	var mesh_list := mesh_library.get_item_list().duplicate()
	mesh_list.append(-1) # Anche una mesh vuota è valida
	var grid : Dictionary = {}
	for x in range(from.x, to.x + 1):
		for y in range(from.y, to.y + 1):
			for z in range(from.z, to.z + 1):
				grid[Vector3i(x, y, z)] = PackedInt32Array(mesh_list)
	return grid

func collapse_cell(pos: Vector3i):
	if collapsed.has(pos):
		return
	var options := possibilities.get(pos, PackedInt32Array())
	if options.is_empty():
		push_error("Nessuna possibilità per la cella %s" % pos)
		return
	var mesh_id := weighted_random(options)
	set_cell_item(pos, mesh_id)
	collapsed[pos] = mesh_id
	possibilities.erase(pos)
	propagate_constraints(pos, mesh_id)

func step_generation():
	if frontier.is_empty():
		print("Generazione completata.")
		return
	var min_entropy := INF
	var best_pos = null
	for pos in frontier.keys():
		var opts = possibilities.get(pos, [])
		if opts.is_empty():
			continue
		var entropy = shannon_entropy(opts)
		if entropy < min_entropy:
			min_entropy = entropy
			best_pos = pos
	if best_pos != null:
		collapse_cell(best_pos)
		update_frontier()

func update_frontier():
	frontier.clear()
	for pos in collapsed.keys():
		for dir in get_directions():
			var n = pos + dir.vector
			if not collapsed.has(n) and possibilities.has(n):
				frontier.add(n) 

func propagate_constraints(origin: Vector3i, mesh_id: int):
	var rule: TiledAdjacencyRule = config.rules.get(mesh_id)
	if rule == null:
		return
	for dir in get_directions():
		var neighbor = origin + dir.vector
		if not possibilities.has(neighbor):
			continue
		var allowed := rule.get(dir.name)
		var current = possibilities[neighbor]
		var filtered := PackedInt32Array()
		for id in current:
			if allowed.has(id):
				filtered.append(id)
		if filtered.size() < current.size():
			possibilities[neighbor] = filtered
			frontier.add(neighbor)

func weighted_random(options: PackedInt32Array) -> int:
	var total_weight := 0.0
	var weights := []
	for id in options:
		var w : float = config.rules.get(id).weight
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
	for id in options:
		var rule: TiledAdjacencyRule = config.rules.get(id)
		total += rule.weight if rule != null else 1.0
	var sum_log := 0.0
	for id in options:
		var rule: TiledAdjacencyRule = config.rules.get(id)
		var w := rule.weight if rule != null else 1.0
		sum_log += w * log(w)
	return log(total) - (sum_log / total)

func get_directions() -> Array:
	return [
		{name = "+X", vector = Vector3i(1, 0, 0)},
		{name = "-X", vector = Vector3i(-1, 0, 0)},
		{name = "+Z", vector = Vector3i(0, 0, 1)},
		{name = "-Z", vector = Vector3i(0, 0, -1)},
		{name = "+Y", vector = Vector3i(0, 1, 0)},
		{name = "-Y", vector = Vector3i(0, -1, 0)},
	]


func _generate_all():
	possibilities = superpositions(grid_from, grid_to)
	collapsed.clear()
	var start_pos = get_starting_position(propagation_direction)
	collapse_cell(start_pos)
	update_frontier()
	while not frontier.is_empty():
		step_generation()


func _get_configuration_warnings():
	if !mesh_library:
		return ["Associa una MeshLibrary a questo nodo"]
	elif !config:
		return ["Associa una MeshConfiguration a questo nodo"]
	elif config.is_empty():
		return ['Configura i collegamenti delle tessere']
	else:
		return []
