extends MeshInstance3D

@onready var player : Player = get_tree().get_first_node_in_group("Player")
var vertical_offset = 4.5

func _process(_delta: float) -> void:
	global_position = player.global_position - Vector3(0,vertical_offset,0)
