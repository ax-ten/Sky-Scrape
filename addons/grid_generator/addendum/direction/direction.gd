extends Resource
class_name Direction3D
@export var name: StringName
@export var vector: Vector3i
const cardinality :int = 3

static func create(name: StringName, vector:Vector3i):
	var d = Direction3D.new()
	d.name = name
	d.vector = vector
	return d
