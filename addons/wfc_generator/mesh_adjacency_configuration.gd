@tool
extends Resource
class_name MeshAdjacencyConfiguration

@export var rules: Dictionary[int, AdjacencyRule] = {}


func get_compatible(id: int, direction: String) -> Array[int]:
	if not rules.has(id):
		rules[id] = AdjacencyRule.new()
	
	var dir_dict := rules[id].get(direction)
	return dir_dict.keys()

func get_weighted_compatible(id: int, direction: String) -> Dictionary[int, float]:
	if not rules.has(id):
		return {}
	return rules[id].get(direction)

func set_rule(id: int, direction: String, compatible_dict: Dictionary[int, float]) -> void:
	if not rules.has(id):
		rules[id] = AdjacencyRule.new()
	rules[id].set(direction, compatible_dict)

func clear():
	rules.clear()

func print_rules():
	for id in rules.keys():
		print("Mesh ID:", id)
		for dir_name in ["X_pos", "X_neg", "Y_pos", "Y_neg", "Z_pos", "Z_neg"]:
			var data = rules[id].get(dir_name)
			if data.size() > 0:
				print("  ", dir_name, "→", data)

func has_rule(mesh_id: int, direction: String) -> bool:
	return rules.has(mesh_id) and rules[mesh_id].get(direction).size() > 0
	
func is_empty() -> bool :
	for id in rules.keys():
		for dir_name in ["X_pos", "X_neg", "Y_pos", "Y_neg", "Z_pos", "Z_neg"]:
			if rules[id].get(dir_name).size() > 0:
				return true
	return false
