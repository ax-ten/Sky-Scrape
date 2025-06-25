# wfc_algorithm.gd
@tool
extends GenerationAlgorithm
class_name MSAlgorithm

func step(grid: GridGenerator) -> void:
	print("Esecuzione Model Synthesis su", grid)
