
@tool
extends Node
class_name PalazzoManager

var last_z := -10
var goal_z : float = 0
var palazzi  := []
const COUNTDOWN = 5
@onready var player :Player= get_tree().get_first_node_in_group("Player")
const distanza_trigger := 40
const cell_size = Vector3(3.4, 0.532, 3.4)

		
func _init() -> void:
	_exit_tree()
	palazzi =[]
	last_z = -10
	goal_z = 0



func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if player:
		var pz :float= player.global_position.z 
		var last_palazzo = palazzi.back()
		if last_palazzo == null or pz > last_palazzo.global_position.z - distanza_trigger:
			istanzia_palazzo()
			

@export_tool_button("istanzia")
var ip := istanzia_palazzo
@export_tool_button("reset")
var r := _init

func istanzia_palazzo() -> PalazzoGenerator:
	var pg = PalazzoGenerator.new()
	add_child(pg)
	pg.generate.call()

	var y := randf_range(-1.5, 1.5)
	var offset_z := mappa_altezza_su_z(y)

	pg.global_position = Vector3(-10, y, last_z)
	#print( pg.palazzo_x, "  ",offset_z)
	last_z += pg.palazzo_x * cell_size.z + offset_z - 2.5
	palazzi.append(pg)

	if palazzi.size() > COUNTDOWN:
		var to_remove = palazzi.pop_front()
		if is_instance_valid(to_remove):
			to_remove.call_deferred("queue_free")
	return pg


func mappa_altezza_su_z(y: float) -> float:
	# Mappa y da -1.5 → 1.5 su un range di profondità z: 6 → 12
	var t := inverse_lerp(-1.5, 1.5, y)  # Normalizzato [0, 1]
	return lerp(6.0, 12.0, t)
	
func _exit_tree() -> void:
	for p in get_children():
		remove_child(p)
		p.call_deferred("queue_free")


	
