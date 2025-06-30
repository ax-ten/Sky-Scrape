extends Node3D

@onready var player : Player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if player:
		position.z = player.global_position.z
	else:
		get_tree().get_first_node_in_group("Player")
