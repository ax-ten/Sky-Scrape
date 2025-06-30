extends CharacterBody3D
class_name Player

@onready var pivot = $Pivot
@onready var mesh = $Pivot/MeshInstance3D
@onready var painter: Painter = $Painter
@onready var sounds: Node = $SlimeSounds
@onready var swipeCD : Timer = $SwipeCoolDown
@onready var jumpCD : Timer = $JumpCoolDown

var cube_size = 1.0
var speed = 8.0
var rolling = false
var jump_speed = 3   
var jump_charge = 1.0  
var jump_accelerator = 15
var jump_max = 5   
var jumping = false
var go = false

signal damage

var last_direction = Vector3.BACK

func _physics_process(delta: float) -> void:
	move_and_slide()
		
	if not is_on_floor():
		painter._on_walking(false)
		velocity += get_gravity() * delta * PI
		reset_scale()
		jumping = true
	else: #se è sul pavimento
		if jumping and go: #se è appena atterrato
			jumping = false
			velocity = Vector3.ZERO
			sounds._reproduce_random(jumping)
			painter._on_landing(jump_charge - 1)
			painter.paint(jump_charge)
			jump_charge = 1
		if not go:
			painter._on_walking(false)
			return
		
		if Input.is_action_pressed("jump") and jump_charge < jump_max:
			charge_jump(delta)
			return
		elif Input.is_action_just_released("jump") or jump_charge >= jump_max:
			release_jump(Vector3.BACK)
			painter._on_landing()
			painter._on_walking(false)
			return
		
			
	if swipeCD.time_left == 0:
		if Input.is_action_just_pressed("ui_left"):
			swipeCD.start()
			await swipe(Vector3.RIGHT)
			return
		elif Input.is_action_just_pressed("ui_right"):
			swipeCD.start()
			await swipe(Vector3.LEFT)
			return

	if not rolling:
		last_direction = Vector3.BACK
		await roll(Vector3.BACK)
		if is_on_floor():
			painter.paint()
		painter._on_walking(true)

func swipe(dir: Vector3):
	var target_position = global_position + dir * 3
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", target_position, 0.1) 
	await tween.finished


func _process(_delta: float) -> void:
	if global_position.y < -10:
		respawn()
		damage.emit()

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
	velocity.y = jump_speed * min(jump_charge, 3) *1.2
	velocity += direction.normalized() * jump_speed * jump_charge / 3 + Vector3.BACK*3
	
func reset_scale():
	pivot.transform = Transform3D.IDENTITY
	mesh.transform = Transform3D.IDENTITY
	mesh.position = Vector3(0, cube_size / 2, 0)
	#var jump_tween = get_tree().create_tween()#.set_trans(Tween.TRANS_ELASTIC)
	#jump_tween.tween_property($Pivot, "scale", Vector3.ONE, speed)
	#await jump_tween.finished


func roll(dir:Vector3, mult: float=1.0):
	rolling = true
	var step = cube_size * mult
	# Step 1: Offset the pivot.
	pivot.translate(dir * step / 2)
	mesh.global_translate(-dir * step / 2)

	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(pivot, "transform",
		pivot.transform.rotated_local(axis, PI/2), 1 / speed)
	await tween.finished

	# Step 3: Finalize the movement and reset the offset.
	transform.origin += dir * step
	var b = mesh.global_transform.basis
	pivot.transform = Transform3D.IDENTITY
	mesh.position = Vector3(0, cube_size / 2, 0)
	mesh.global_transform.basis = b
	rolling = false

	if is_on_floor():
		sounds._reproduce_random()

	## Cast a ray before moving to check for obstacles
	var space = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(
		mesh.global_position,
		mesh.global_position + dir * step,
		collision_mask,
		[self]
	)
	var collision = space.intersect_ray(ray)
	if collision:
		tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "global_position", global_position+Vector3(0,1,0),0.05)
		await tween.finished

	

func respawn():
	get_tree().call_group("playerspawner", "respawn")
