extends MeshInstance3D
class_name PaintMesh

@export var paint: Paint
var material: StandardMaterial3D


func _ready() -> void:
	material = StandardMaterial3D.new()
	material.albedo_texture = paint.mono_gradient_texture()
	material_overlay = material
	material_override = material
