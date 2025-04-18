extends WorldEnvironment

var player : CharacterBody3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if player:
		environment.volumetric_fog_density = min(-player.position.z /1000, 5)
