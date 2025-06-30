extends Node3D
class_name  ItemSpawner

@onready var player : Player = get_tree().get_first_node_in_group("Player")
var z_reached : float = 0
var item_spawned : int = 0
@onready var positions = $Positions.get_children()
@export var goal_distance := 10
@export var freq_modifier := 1
@export var spawnables : Array[PackedScene]
@export var z_distance = 10

func _init() -> void:
	z_reached = 0
	item_spawned = 0



func _process(_delta: float) -> void:
	await get_tree().process_frame
	global_position.z = player.global_position.z + z_distance
	global_position.y = player.global_position.y
	z_reached = max(z_reached, player.position.z)
	if z_reached / goal_distance * freq_modifier > item_spawned:
		spawn_item(random_item())


func spawn_item(scene: PackedScene):
	item_spawned += 1
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)

	var timer = Timer.new()
	timer.one_shot = true
	instance.add_child(timer)
	timer.timeout.connect(func():
		instance.get_parent().remove_child(instance)
		instance.call_deferred("queue_free")
	)

	# Posizione target sulla X/Z
	var target_pos = random_position()
	var ray_origin = target_pos
	var ray_target = target_pos - Vector3.UP * 100.0

	var space = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	query.exclude = [player]
	# query.collision_mask = ...  # opzionale, se vuoi limitarlo a certi layer

	var result = space.intersect_ray(query)
	var final_y := 0.0

	if result:
		var collider = result.collider
		var collision_y = result.position.y

		if collider is PalazzoGenerator:
			final_y = collision_y + (3.0 if randf() < 0.5  else 1.0)
		else:
			final_y = collision_y + 1.0
	else:
		final_y = player.global_position.y + 2.0

	var final_pos = Vector3(target_pos.x, final_y, target_pos.z)

	# Posizione iniziale (più bassa per il rimbalzo)
	instance.global_position = final_pos - Vector3.UP * 4.0

	# Tween con rimbalzo
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(instance, "global_position", final_pos, 0.4)
	await tween.finished

	if is_instance_valid(timer):
		timer.start(5)


func random_item() -> PackedScene:
	return spawnables[randi_range(0, len(spawnables)-1)]


func random_position() -> Vector3:
	return positions[randi_range(0,len(positions)-1)].global_position
