@tool
extends Resource
class_name GenerationAlgorithm
# Base class for all generation strategies
const AIR = GridGenerator.INVALID_CELL_ITEM
const TIMEOUT : float = 1


static func new_timer() -> Timer :
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = TIMEOUT
	timer.timeout.connect(func():
		timer.get_parent().remove_child(timer)
		timer.queue_free()
		)
	return timer


func populate(grid: GridGenerator) -> void:
	var t : Timer
	while not grid.validity():
		t = new_timer()
		grid.add_child(t)
		t.start()
		while step(grid):
			if t.get_parent() != grid:
				break


func collapse_cell(grid: GridGenerator, pos: Vector3i):
	var options := grid.possibilities.get(pos, PackedInt32Array([AIR]))
	print("opzioni in ", pos, ": ",options)
	var mesh_id := weighted_random(grid.get_weights(options), options)
	#print("pos: %s\nOpzioni: %s\nScelta: mesh_id %s - %s" % [str(pos), str(options), str(mesh_id), grid.mesh_library.get_item_name(mesh_id)])
	if mesh_id != AIR:
		grid.set_cell_item(pos, mesh_id)
	grid.collapsed.add(pos)
	grid.possibilities.erase(pos)


func weighted_random(weights, options: PackedInt32Array) -> int:
	var r = randf_range(0, _sum(weights))
	for i in options.size():
		r -= weights[i]
		if r <= 0.0:
			return options[i]
	return -1


func step(grid: GridGenerator) -> bool:
	push_error("Metodo step_generation non implementato.")
	return false


func _sum(array) -> float:
	var sum = 0.0
	for e in array:
		sum += e
	return sum
