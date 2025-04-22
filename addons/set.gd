extends GDScript
class_name Set

# Simple Set implementation using Dictionary
# Supports basic add/remove/has/clear and iteration

var _data: Dictionary = {}

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
	return _data.keys()

func to_string() -> String:
	return ", ".join(_data.keys().map(func(v): return str(v)))
