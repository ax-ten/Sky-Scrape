extends Node3D

@onready var player : Player = get_tree().get_first_node_in_group("Player")
var starting_position := Vector3(0,0,14)

func _ready() -> void:
	respawn()
	
func respawn(death:bool=false) ->void:
	if death:
		player.global_position = starting_position
	else:
		player.global_position.y += 20
	
