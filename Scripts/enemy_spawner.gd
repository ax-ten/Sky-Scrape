@tool
extends Node3D

@onready var ui = get_tree().get_first_node_in_group("UI")
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@export var spawn_curve : Curve

const MAX_GABBIANI = 6
var gabbiani: Array = []

var gabbiano_scene = preload("res://Nodes/Enemies/gabbiano.tscn")
#var vaso_scene #= preload()

func _init() -> void:
	for g in gabbiani:
		if is_instance_valid(g):
			gabbiani.erase(g)
			g.call_deferred("queue_free")
	var gabbiani: Array = []
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var chance := spawn_curve.sample_baked(ui.cumulative)
	if randf() < chance * delta:
		spawn_gabbiano()

@export_tool_button("spawn")
var sg := spawn_gabbiano

@export_tool_button("init")
var it := _init

func spawn_gabbiano():
	var gabbiano : Enemy = gabbiano_scene.instantiate()
	add_child(gabbiano)
	gabbiano.global_position = player.global_position + Vector3(
		randf_range(-5, 5),
		2,
		randf_range(20,30)
	)
	gabbiano.target = player.global_position 
	gabbiani.append(gabbiano)

	if gabbiani.size() > MAX_GABBIANI:
		var to_remove = gabbiani.pop_front()
		if is_instance_valid(to_remove):
			to_remove.call_deferred("queue_free")
