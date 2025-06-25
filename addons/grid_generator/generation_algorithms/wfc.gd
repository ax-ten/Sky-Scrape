# wfc_algorithm.gd
@tool
extends GenerationAlgorithm
class_name WFCAlgorithm


func step(grid: GridGenerator) -> bool:
	var pos = least_entropy(grid)
	if not pos:
		print("non riesco a trovare la minor entropia")
		if grid.frontier.is_empty():
			grid.frontier = Set.difference(grid.possibilities.keys(), grid.collapsed)
			if grid.frontier.is_empty():
				grid.frontier = Set.new(grid.possibilities.keys())
				#return false
		pos = grid.frontier.get_random()
		if not pos:
			return false
	collapse_cell(grid, pos)
	grid.propagate_constraints(pos)
	return true


func least_entropy(grid: GridGenerator) -> Vector3i:
	var min_entropy := INF
	var best_pos : Vector3i
	print("frontier: ", grid.frontier)
	for pos in grid.frontier:
		var options := grid.possibilities.get(pos, null)
		if not options:
			print("no opts at ", pos)
			grid.frontier.remove(pos)
			continue
		if options.size() == 1:
			grid.frontier.remove(best_pos)
			return pos
		var entropy = shannon_entropy(grid.get_weights(options)) + randf_range(0.0, 0.01)
		if entropy < min_entropy:
			min_entropy = entropy
			best_pos = pos
	grid.frontier.remove(best_pos)
	
	return best_pos


func shannon_entropy(weights) -> float:
	var total := 0.0
	var sum_log := 0.0
	for w in weights:
		total += w
		sum_log += w * log(w)
	return log(total) - (sum_log / total)
