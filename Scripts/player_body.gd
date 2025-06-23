extends CharacterBody3D
class_name Player

@onready var pivot = $Pivot
@onready var mesh = $Pivot/MeshInstance3D
@onready var painter: Painter = $Painter
@onready var sounds: Node = $SlimeSounds

var cube_size = 1.0
var speed = 6.0
var rolling = false
var jump_speed = 3   
var jump_charge = 1.0  
var jump_accelerator = 5
var jump_max = 3   
var jumping = false
var is_looking_up = false

var directions = {
		"ui_up": Vector3.FORWARD,
		"ui_down": Vector3.BACK,
		"ui_right": Vector3.RIGHT,
		"ui_left": Vector3.LEFT,
	}
var last_direction = Vector3.FORWARD

func _physics_process(delta: float) -> void:
	
	move_and_slide()
	if not is_on_floor():
		# applica gravità
		velocity += get_gravity() * delta * PI
		reset_scale()
		jumping = true
	else:
		# resetta la velocità appena atterra
		if jumping:
			sounds._reproduce_random(jumping)
			jumping = false
			painter._on_landing(jump_charge-1)
			painter.paint(jump_charge)
			velocity = Vector3.ZERO
			jump_charge = 1.0
		
		if Input.is_action_pressed("ui_accept"):
			charge_jump(delta)
			is_looking_up = (last_direction == Vector3.FORWARD)
			return

		elif Input.is_action_just_released("ui_accept"):
			release_jump(last_direction)
			painter._on_landing()
			is_looking_up = false
			return
		

	if rolling:
		painter._on_walking(true)
		return
	for action in directions.keys():
		if Input.is_action_pressed(action):
			last_direction = directions[action]
			roll(last_direction)
			if is_on_floor():
				painter.paint()
			break
			
	painter._on_walking(false)



func _process(delta: float) -> void:
	if global_position.y < -10:
		respawn()

func charge_jump(delta):
	# Incrementa il charge del salto
	jump_charge = min(jump_charge + jump_accelerator * delta, jump_max)
	
	# Calcola il fattore di base e altezza
	var base = max(1, 1 + jump_charge * 0.2)
	var height = max(0.4, 1 - jump_charge * 0.2)

	# Anima la deformazione
	var jump_tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	jump_tween.tween_property($Pivot, "scale", Vector3(base, height, base), 0.01)
	await jump_tween.finished


func release_jump(direction):
	#applica accelerazione del salto
	velocity.y = jump_speed * jump_charge *1.2
	velocity += direction.normalized() * jump_speed * jump_charge / 3 + Vector3.BACK*3
	
func reset_scale():
	$Pivot.scale = Vector3.ONE
	#var jump_tween = get_tree().create_tween()#.set_trans(Tween.TRANS_ELASTIC)
	#jump_tween.tween_property($Pivot, "scale", Vector3.ONE, speed)
	#await jump_tween.finished


func roll(dir):
	rolling = true
	# Step 1: Offset the pivot.
	pivot.translate(dir * cube_size / 2)
	mesh.global_translate(-dir * cube_size / 2)

	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_IN)
	tween.tween_property(pivot, "transform",
			pivot.transform.rotated_local(axis, PI/2), 1 / speed)
	await tween.finished

	# Step 3: Finalize the movement and reset the offset.
	transform.origin += dir * cube_size
	var b = mesh.global_transform.basis
	pivot.transform = Transform3D.IDENTITY
	mesh.position = Vector3(0, cube_size / 2, 0)
	mesh.global_transform.basis = b
	rolling = false
	if is_on_floor():
		sounds._reproduce_random()
	
	# Cast a ray before moving to check for obstacles
	var space = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(mesh.global_position,
		mesh.global_position + dir * cube_size, collision_mask, [self])
	var collision = space.intersect_ray(ray)
	if collision:
		print("collision detected")
		return
	

func respawn():
	get_tree().call_group("playerspawner", "respawn")
