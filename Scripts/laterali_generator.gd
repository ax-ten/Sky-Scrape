@tool
extends Node3D
class_name LateraliGenerator

var start_position := Vector3( 5.8 ,-0.5, 1.11)
var laterale_scene = preload("res://Assets/PezziPalazzo/laterale.tscn")
var parete_scene = preload("res://Nodes/Palazzo/parete.tscn")
@export var gridgen : GridGenerator


#
#func _ready() -> void:
	#_deploy()
func _ready() -> void:
	if not gridgen:
		for c in get_parent().get_children():
			if c != self and c is GridGenerator:
				gridgen = c
	
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
func _deploy()  -> void:
	_ready()
	var height := gridgen._to.z - gridgen._from.z
	var base := gridgen._to.x - gridgen._from.x
	var laterali_distance := base * gridgen.cell_size.z
	var x_distance := gridgen.cell_size.x
	for x in range(height):
		var parete : Node3D = parete_scene.instantiate()
		parete.position = start_position + Vector3(x_distance * (x-0.24), -3.96, 0.4)
		#parete.position = start_position + Vector3(x_distance, -3.96, 0.4)
		parete.rotate_y(PI)
		add_child(parete)
		for z in [0, laterali_distance]:
			var laterale : Node3D = laterale_scene.instantiate()
			add_child(laterale)
			laterale.position = start_position + Vector3(x_distance * x, 0 ,z)
			parete.scale = 0.2 * Vector3.ONE

@export_tool_button("deploy") var d : Callable = _deploy
