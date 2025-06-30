@tool
extends Node3D
class_name PalazzoGenerator

@export var gridgen : GridGenerator
@export var lateraligen : LateraliGenerator

@export_range(3,8) var palazzo_x : int = 3
@export_range(4, 7) var palazzo_y : int = 6

@export_tool_button("generate")
var generate : Callable = func():
	await _ready()
	#gridgen._to = Vector3i(palazzo_x, 2, palazzo_y)
	gridgen.generation.populate(gridgen)
	lateraligen._deploy()
	
	
func _ready() -> void:
	gridgen._to = Vector3i( randi_range(3,8), 2, randi_range(4, 7))
	palazzo_x = gridgen._to.x
	palazzo_y = gridgen._to.z
	await get_tree().process_frame
	gridgen.clear_grid.call()	
	#genera palazzo_x
	#genera palazzo_y
func _init() -> void:
	if gridgen and lateraligen:
		return
	gridgen = GridGenerator.new()
	lateraligen = LateraliGenerator.new()
	add_child(gridgen)
	add_child(lateraligen)
