# wfc_algorithm.gd
@tool
extends GenerationAlgorithm
class_name WFCAlgorithm


func step(grid: GridGenerator) -> void:
	var pos = least_entropy(grid)
	collapse_cell(grid, pos)
	grid.propagate_constraints(pos)


func collapse_cell(grid: GridGenerator, pos: Vector3i):
	var options := grid.possibilities.get(pos, PackedInt32Array([air]))
	var mesh_id := weighted_random(grid.get_weights(options), options)
	#print("pos: %s\nOpzioni: %s\nScelta: mesh_id %s - %s" % [str(pos), str(options), str(mesh_id), grid.mesh_library.get_item_name(mesh_id)])
	if mesh_id != air:
		grid.set_cell_item(pos, mesh_id)
	#grid.collapsed.add(pos)
	grid.possibilities.erase(pos)
	

func least_entropy(grid: GridGenerator) -> Vector3i:
	var min_entropy := INF
	var frontier: Set = grid.frontier
	var best_pos = Vector3i.ZERO
	for pos in frontier:
		var options := grid.possibilities.get(pos, null)
		if not options:
			continue
		if options.size() == 1:
			return pos
		var entropy = shannon_entropy(grid.get_weights(options)) + randf_range(0.0, 0.001)
		if entropy < min_entropy:
			min_entropy = entropy
			best_pos = pos
	return best_pos


func weighted_random(weights, options: PackedInt32Array) -> int:
	var r = randf_range(0, sum(weights))
	for i in options.size():
		r -= weights[i]
		if r <= 0.0:
			return options[i]
	return options[-1]


func shannon_entropy(weights) -> float:
	var total := 0.0
	var sum_log := 0.0
	for w in weights:
		total += w
		sum_log += w * log(w)
	return log(total) - (sum_log / total)



func sum(array) -> float:
	var sum = 0.0
	for e in array:
		sum += e
	return sum
