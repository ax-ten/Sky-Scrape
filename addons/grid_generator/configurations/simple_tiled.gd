@tool
extends _MeshAdjacencyConfiguration
class_name SimpleAdjacencyConfiguration


@export var rules: Dictionary[int, TiledAdjacencyRule] = {}

#@export_tool_button("update air_rule", "new") 
#var up = func():
	#rules[-1] = air_rule()
	
func _init() -> void:
	rules[-1] = air_rule()


func air_rule() -> TiledAdjacencyRule:
	var ar := TiledAdjacencyRule.new()
	for mesh_id in rules:
		var rule := rules[mesh_id]
		for dir in rule.DIRECTIONS:
			var allowed := rule.get(dir)
			if -1 in allowed:
				ar._append(opposite_direction(dir),mesh_id)
	ar.weight = 3.0
	return ar

static func opposite_direction(dir:StringName) -> StringName:
	match dir:
		"X+": return "X-"
		"X-": return "X+"
		"Y+": return "Y-"
		"Y-": return "Y+"
		"Z+": return "Z-"
		"Z-": return "Z+"
		_: return dir

func get_compatible(id: Variant, direction: Vector3i) -> Array:
	if rules.get(id, null) == null:
		return []

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida per il WFC" % [direction])
		return []

	return rules[id].get(dir_name)


func _validate_property(property: Dictionary):
	if property.name == "rules" and property.values()[0] is TiledAdjacencyRule:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func get_weighted_compatible(id: int, direction: Vector3i) -> PackedInt32Array:
	if not rules.has(id):
		return TiledAdjacencyRule.EMPTY

	var dir_name: StringName = VECTOR_TO_DIR.get(direction, null)
	if dir_name == null:
		push_warning("Direzione %s non valida per il WFC" % [direction])
		return TiledAdjacencyRule.EMPTY
	return rules[id].get(dir_name)
#
	#
#func is_empty() -> bool :
	#for rule in rules.values():
		#if rule and not rule.is_empty():
			#return false
	#return true
