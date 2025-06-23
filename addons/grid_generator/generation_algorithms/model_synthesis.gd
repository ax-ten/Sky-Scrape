# wfc_algorithm.gd
@tool
extends GenerationAlgorithm
class_name MSAlgorithm

var order: Array
var current_step := 0

func _reset_state() -> void:
	order.clear()



func step(grid: GridGenerator) -> bool:
	if not order:
		order = unroll(grid)
		current_step = 0
	if current_step >= order.size():
		print("Non c'è altro da generare")
		return false
	var pos = order[current_step]
	#if current_step == 0:
		#pos = Vector3i(0,1,0)
	collapse_cell(grid, pos)
	current_step += 1
	grid.propagate_constraints(pos)
	return true


func unroll(grid: GridGenerator) -> Array :
	order = []
	for z in range(grid._from.x, grid._to.x) :
		for y in range(grid._from.y, grid._to.y) :
			for x in range(grid._from.z, grid._to.z) :
				order.append(Vector3i(x,y,z))
	return order
