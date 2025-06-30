extends CharacterBody3D
class_name Enemy

@onready var ui = get_tree().get_first_node_in_group("UI")
@onready var player : Player = get_tree().get_first_node_in_group("Player")
var target : Vector3
const SPEED := 200
const TURN_SPEED := 2
signal hit

func _ready() -> void:
	connect("hit",  ui._on_damage)

func _physics_process(delta: float) -> void:
	if not target:
		return

	var direction := target - global_position

	# Muovi nella direzione
	velocity = direction.normalized() * SPEED * delta
	move_and_slide()

	# Ruota verso la direzione in modo graduale
	var current := transform.basis.get_rotation_quaternion()
	var target_rotation := Basis(Vector3.FORWARD, 0).looking_at(direction.normalized(), Vector3.UP).get_rotation_quaternion()
	var new_rot := current.slerp(target_rotation, delta * TURN_SPEED)
	transform.basis = Basis(new_rot)

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		#print('ho colpito er giocatore, coccodè')
		hit.emit()
		
