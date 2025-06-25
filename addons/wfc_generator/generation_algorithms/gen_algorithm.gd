@tool
extends Resource
class_name GenerationAlgorithm
# Base class for all generation strategies
const air = GridGenerator.INVALID_CELL_ITEM

func populate(grid: GridGenerator) -> void:
	while not grid.possibilities.is_empty():
		step(grid)


func step(grid: GridGenerator) -> void:
	push_error("Metodo step_generation non implementato.")
