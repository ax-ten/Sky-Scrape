@tool
extends Node
class_name GenerationAlgorithm
# Base class for all generation strategies
const AIR = GridGenerator.INVALID_CELL_ITEM
const TIMEOUT : float = 2
signal step_completed
var is_populating 


func _init() -> void:
	is_populating = false


static func new_timer(wait=TIMEOUT) -> Timer :
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = wait
	t.timeout.connect(func():
		t.get_parent().remove_child(t)
		t.queue_free()
		)
	return t


func populate(grid: GridGenerator) -> void:
	
	if is_populating:
		print("populate già in corso, ignorato")
		return
	is_populating = true
	
	var t : Timer
	var validity := false
	while not validity:
		t = new_timer()
		grid.add_child(t)
		t.start()
		
		while do_step(grid):
			await get_tree().process_frame
			
			if not is_instance_valid(t):
				print("t non valido")
				break 
			if t.get_parent() != grid:
				print("t senza parente")
				break
			
		if is_instance_valid(t):
			t.stop()
		validity = true #grid.validity()
	is_populating = false
	


func collapse_cell(grid: GridGenerator, pos: Vector3i):
	var options := grid.possibilities.get(pos, PackedInt32Array([AIR]))
	#print("opzioni in ", pos, ": ",options)
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


func do_step(grid: GridGenerator) -> bool:
	var result := step(grid)  
	step_completed.emit()
	return result


func step(grid: GridGenerator) -> bool:
	push_error("Metodo step_generation non implementato.")
	return false


func _sum(array) -> float:
	var sum = 0.0
	for e in array:
		sum += e
	return sum
