extends RefCounted
class_name Set

var _data: Dictionary = {}

func _init(starting:Variant=[]) -> void:
	if typeof(starting) == TYPE_PACKED_INT32_ARRAY:
		for e in starting:
			add(e)

func add(value) -> void:
	_data[value] = true

func remove(value) -> void:
	_data.erase(value)

func has(value) -> bool:
	return _data.has(value)

func clear() -> void:
	_data.clear()

func is_empty() -> bool:
	return _data.is_empty()

func size() -> int:
	return _data.size()

func values() -> Array:
	return _data.keys().duplicate()


func _to_string() -> String:
	return "(" + ", ".join(values().map(func(v): return str(v))) + ")"

func duplicate() -> Set:
	var new_set = Set.new()
	for value in values():
		new_set.add(value)
	return new_set


static func intersect(s1: Set, s2: Set) -> Set:
	var filtered := Set.new()
	var condition := s1.size() < s2.size()
	var S := s1 if condition else s2
	var s := s2 if condition else s1
	for e in S:
		if s.has(e):
			filtered.add(e)
	#print("s1: %s\ns2: %s\nfiltrato:%s" % [str(s1), str(s2), str(filtered)])
	return filtered


## Supporto per "for element in my_set"
func _iter_init(iter: Array) -> bool:
	iter[0] = 0
	return _data.size() > 0

func _iter_next(iter: Array) -> bool:
	iter[0] += 1
	return iter[0] < _data.size()

func _iter_get(iter: Variant) -> Variant:
	var ad = Array(_data.keys())
	return ad[iter]
