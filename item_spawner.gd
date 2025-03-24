extends Node3D
class_name  ItemSpawner

var player : Player
var z_reached : float = 0
var item_spawned : int = 0
@onready var positions = $Positions.get_children()
@export var goal_distance := 10
@export var freq_modifier := 1
@export var spawnables : Array[PackedScene]
@export var z_distance = 5


func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("Player")


func _process(delta: float) -> void:
	global_position.z = player.global_position.z - z_distance
	z_reached = max(z_reached, -player.position.z)
	if z_reached / goal_distance * freq_modifier > item_spawned:
		spawn_item(random_item())


func spawn_item(scene:PackedScene):
	item_spawned +=1
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = random_position()
	#$Label.text = str(item_spawned)
	#instance.velocity.z = instance.get_gravity()


func random_item() -> PackedScene:
	return spawnables[randi_range(0, len(spawnables)-1)]


func random_position() -> Vector3:
	return positions[randi_range(0,len(positions)-1)].global_position
