extends Node3D

@export var playerscene :PackedScene
var player :CharacterBody3D

func _ready() -> void:
	player = playerscene.instantiate()
	add_child(player)
	respawn()
	
func respawn() ->void:
	player.global_position = global_position
	
