# wfc_algorithm.gd
@tool
extends GenerationAlgorithm
class_name WFCAlgorithm


func step(grid: GridGenerator) -> bool:
	var pos = least_entropy(grid)
	if not pos:
		print("non riesco a trovare la minor entropia")
		return false
	collapse_cell(grid, pos)
	grid.propagate_constraints(pos)
	return true


func least_entropy(grid: GridGenerator) -> Vector3i:
	var min_entropy := INF
	var frontier: Set = grid.frontier
	var best_pos = null
	for pos in frontier:
		var options := grid.possibilities.get(pos, null)
		if not options:
			#print("no opts at ", pos)
			frontier.remove(pos)
			continue
		if options.size() == 1:
			return pos
		var entropy = shannon_entropy(grid.get_weights(options)) + randf_range(0.0, 0.001)
		if entropy < min_entropy:
			min_entropy = entropy
			best_pos = pos
	return best_pos


func shannon_entropy(weights) -> float:
	var total := 0.0
	var sum_log := 0.0
	for w in weights:
		total += w
		sum_log += w * log(w)
	return log(total) - (sum_log / total)
