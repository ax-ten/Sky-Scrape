@tool
extends Node3D
class_name Visualizer

var distance := Vector3(3.5, 1.5, 3.5)
@export var ph_scene := preload("res://Scenes/placeholder.tscn")

func placehold(pos:Vector3, gravity:float):
	var cube :MeshInstance3D=  ph_scene.instantiate().duplicate()
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(gravity,0,0,1)
	add_child(cube)
	cube.set_surface_override_material(0, mat)
	cube.global_position = pos * distance + Vector3(1.5, 1.5, 1.5)
	cube.visible = true


func visualize(wave:Dictionary):
	for node in get_children():
		remove_child(node)
		node.queue_free()
	##await  get_tree().process_frame
	var max_gravity = get_max_entropy(wave.values())
	if max_gravity == 0:
		return
	for pos in wave.keys():
		#pass
		placehold(pos, wave[pos].size() / max_gravity)

func get_max_entropy(possibilities) -> int:
	var max_entropy = 0
	for possibility in possibilities:
		if possibility.size() > max_entropy:
			max_entropy = possibility.size()
	return max_entropy
